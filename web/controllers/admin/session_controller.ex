defmodule PhoenixGuardian.Admin.SessionController do
  @moduledoc """
  Provides login and logout for the admin part of the site.
  We keep the logins seperate rather than use a permission for this because keeping the tokens in
  separate locations allows us to more easily manage the different requirements between the
  normal site and the admin site
  """
  use PhoenixGuardian.Web, :admin_controller

  alias PhoenixGuardian.UserFromAuth
  alias PhoenixGuardian.User

  # We still want to use Ueberauth for checking the passwords etc
  # we have everything we need to check email / passwords and oauth already
  # but we only want to provide access for folks using email/pass
  plug Ueberauth, base_path: "/admin/auth", providers: [:identity]

  # Make sure that we have a valid token in the :admin area of the session
  # We've aliased Guardian.Plug.EnsureAuthenticated in our PhoenixGuardian.Web.admin_controller macro
  plug EnsureAuthenticated, [key: :admin, handler: __MODULE__] when action in [:delete, :impersonate, :stop_impersonating]

  def new(conn, _params, current_user, _claims) do
    render conn, "new.html", current_user: current_user
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_failure: fails}} = conn, _params, current_user, _claims) do
    conn
    |> put_flash(:error, hd(fails.errors).message)
    |> render("new.html", current_user: current_user)
  end

  # In this function, when sign in is successful we sign_in the user into the :admin section
  # of the Guardian session
  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params, current_user, _claims) do
    case UserFromAuth.get_or_insert(auth, current_user, Repo) do
      {:ok, user} ->
        if user.is_admin do
          conn
          |> put_flash(:info, "Signed in as #{user.name}")
          |> Guardian.Plug.sign_in(user, :access, key: :admin, perms: %{default: Guardian.Permissions.max})
          |> redirect(to: admin_user_path(conn, :index))
        else
          conn
          |> put_flash(:error, "Unauthorized")
          |> redirect(to: admin_login_path(conn, :new))
        end
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not authenticate")
        |> render("new.html", current_user: current_user)
    end
  end

  def logout(conn, _params, _current_user, _claims) do
    conn
      |> Guardian.Plug.sign_out(:admin)
      |> put_flash(:info, "admin signed out")
      |> redirect(to: "/")
  end

  def impersonate(conn, params, _current_user, _claims) do
    user = Repo.get(User, params["user_id"])
    conn
    |> Guardian.Plug.sign_out(:default)
    |> Guardian.Plug.sign_in(user, :access, perms: %{default: Guardian.Permissions.max})
    |> redirect(to: "/")
  end

  def stop_impersonating(conn, _params, _current_user, _claims) do
    conn
    |> Guardian.Plug.sign_out(:default)
    |> redirect(to: admin_user_path(conn, :index))
  end
end
