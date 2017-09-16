defmodule PhoenixGuardianWeb.Admin.UserController do
  use PhoenixGuardianWeb, :admin_controller

  alias PhoenixGuardian.User

  # Make sure that we have a valid token in the :admin area of the session
  # We've aliased Guardian.Plug.EnsureAuthenticated in our PhoenixGuardian.Web.admin_controller macro
  plug EnsureAuthenticated, handler: __MODULE__, key: :admin

  def index(conn, _params, current_user, _claims) do
    users = Repo.all(User)
    render conn, "index.html", users: users, current_user: current_user
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Admin authentication required")
    |> redirect(to: admin_login_path(conn, :new))
  end
end
