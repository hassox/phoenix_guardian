defmodule PhoenixGuardian.AuthController do
  @moduledoc """
  Handles the Überauth integration.
  This controller implements the request and callback phases for all providers.
  The actual creation and lookup of users/authorizations is handled by UserFromAuth
  """
  use PhoenixGuardian.Web, :controller

  alias PhoenixGuardian.UserFromAuth

  plug Ueberauth

  # We need to load the admin JWT if present so that when we logout
  # guardian is aware of it to revoke correclty
  # The reason we need to do this is because we're using a wholesale sign_out call.
  #
  # If in the logout function we were to call
  #
  #     Guardian.Plug.sign_out(:default)
  #
  # We'd only sign out of the normal session
  # Instead we sign out of the entire session to make sure that the session is cleared.
  # This is the reason we need to load it - because it only exists in the session - and if we
  # clear out the session before we're able to revoke the token will stay in our DB
  plug Guardian.Plug.VerifySession, [key: :admin] when action in [:logout]

  def login(conn, _params, current_user, _claims) do
    render conn, "login.html", current_user: current_user, current_auths: auths(current_user)
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_failure: fails}} = conn, _params, current_user, _claims) do
    conn
    |> put_flash(:error, hd(fails.errors).message)
    |> render("login.html", current_user: current_user, current_auths: auths(current_user))
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params, current_user, _claims) do
    case UserFromAuth.get_or_insert(auth, current_user, Repo) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Signed in as #{user.name}")
        |> Guardian.Plug.sign_in(user, :token, perms: %{default: Guardian.Permissions.max})
        |> redirect(to: private_page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not authenticate")
        |> render("login.html", current_user: current_user, current_auths: auths(current_user))
    end
  end

  def logout(conn, _params, current_user, _claims) do
    if current_user do
      conn
      # This clears the whole session.
      # We could use sign_out(:default) to just revoke this token
      # but I prefer to clear out the session. This means that because we
      # use tokens in two locations - :default and :admin - we need to load it (see above)
      |> Guardian.Plug.sign_out
      |> put_flash(:info, "Signed out")
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:info, "Not logged in")
      |> redirect(to: "/")
    end
  end

  defp auths(nil), do: []
  defp auths(%PhoenixGuardian.User{} = user) do
    Ecto.Model.assoc(user, :authorizations)
      |> Repo.all
      |> Enum.map(&(&1.provider))
  end
end
