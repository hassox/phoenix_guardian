defmodule PhoenixGuardian.PasswordController do
  use PhoenixGuardian.Web, :controller

  alias PhoenixGuardian.{Authorization, Email, Mailer, User}

  @max_token_age 172_800 # reset token good for 48 hours

  # new sets up the request for a new password (reset) form
  # asks user for email
  def new(conn, params), do: new(conn, params, nil, nil)
  def new(conn, _params, current_user, _claims) do
    render conn, "new.html", current_user: current_user
  end

  # create checks that user w/ email exists and...
  # authorization is identity provider
  # if not user, user not found message
  # if not auth w/ identity provider, message that they should login via Facebook
  # if there is user w/ identity auth, create token from auth id & send link to edit action via email
  def create(conn, params), do: create(conn, params, nil, nil)
  def create(conn, %{"email" => email}, current_user, _claims) do
    user = Repo.get_by(User, email: email)

    if user do
      manage_password_reset_email user, conn
    else
      conn
      |> put_flash(:error, "Sorry! We couldn't find an account for #{email}.")
      |> render("new.html", current_user: current_user)
    end
  end

  def edit(conn, params), do: edit(conn, params, nil, nil)
  def edit(conn, %{"token" => token}, current_user, _claims) do
    # authorization.id comes in as a token within expiry that can verify
    case Phoenix.Token.verify(PhoenixGuardian.Endpoint, "auth", token, max_age: @max_token_age) do
      {:ok, id} ->
        # get matching authorization so we can update its token (aka password for identity provider)
        # even though we have id, limit to identity provider so attackers can't reset tokens for other provider types
        authorization = Repo.get_by!(Authorization, id: id, provider: "identity")
        render(conn, "edit.html", token: token, current_user: current_user)
      {:error, :expired} -> report_expired(conn)
      {:error, :invalid} -> return_invalid(conn)
    end
  end

  # logged in user editing their password
  def edit(conn, _params, %User{} = current_user, _claims) do
    current_user = current_user |> Repo.preload(:authorizations)
    auth = identity_auth_for(current_user)

    if auth do
      render(conn,
             "edit.html",
             token: Phoenix.Token.sign(PhoenixGuardian.Endpoint, "auth", auth.id),
             current_user: current_user)
    else
      redirect_to_facebook_login conn
    end
  end

  # assume that logged out user w/ no token is attack, return 404
  def edit(conn, _params, _current_user = nil, _claims) do
    return_invalid(conn)
  end

  def update(conn, params), do: edit(conn, params, nil, nil)
  # double check token
  # return error if not valid match for auth
  # update auth's token value w/ submitted password
  # redirect to login form
  def update(conn, %{"token" => token, "password" => password}, current_user, _claims) do
    case Phoenix.Token.verify(PhoenixGuardian.Endpoint, "auth", token, max_age: @max_token_age) do
      {:ok, id} -> update_token_with_password(id, password, conn, token, current_user)
      {:error, :expired} -> report_expired(conn)
      {:error, :invalid} -> return_invalid(conn)
    end
  end

  # get matching authorization so we can update its token (aka password for identity provider)
  # even though we have id, limit to identity provider so attackers can't reset tokens for other provider types
  defp update_token_with_password(id, password, conn, token, current_user) do
    authorization = Repo.get_by!(Authorization, id: id, provider: "identity")
    changeset = Authorization.hash_token_changeset(authorization, %{token: password})

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(to: auth_path(conn, :login, "identity"))
      {:error, _changeset} ->
        # TODO error feedback for user
        render(conn, "edit.html", token: token, current_user: current_user)
    end
  end

  defp identity_auth_for(user) do
    user.authorizations
    |> Enum.filter(fn auth -> auth.provider == "identity" end)
    |> List.first
  end

  defp redirect_to_facebook_login(conn) do
    conn
    |> put_flash(:error, "Looks like you used Facebook to login. Please click Facebook button below to login.")
    |> redirect(to: auth_path(conn, :login, "identity"))
  end

  defp report_expired(conn) do
    conn
    |> put_flash(:error, "Sorry! Your reset request has expired. Please try again.")
    |> redirect(to: auth_path(conn, :login, "identity"))
  end

  defp return_invalid(conn) do
    # assumes that invalid is attack, just return not found error
    conn
    |> put_layout(false)
    |> put_status(404)
    |> render(PhoenixGuardian.ErrorView, "404.html")
  end

  defp manage_password_reset_email(user, conn) do
    user = user |> Repo.preload(:authorizations)
    auth = identity_auth_for(user)

    if auth do
      # create token and send reset email
      user
      |> Email.password_reset_email(Phoenix.Token.sign(PhoenixGuardian.Endpoint, "auth", auth.id))
      |> Mailer.deliver_later

      conn
      |> put_flash(:info, "A link to reset your password has been sent to #{user.email}")
      |> redirect(to: auth_path(conn, :login, "identity"))
    else
      redirect_to_facebook_login conn
    end
  end
end
