defmodule PhoenixGuardian.Api.V1.UserController do
  use PhoenixGuardian.Web, :controller

  alias PhoenixGuardian.User
  alias PhoenixGuardian.SessionController

  plug Guardian.Plug.EnsureAuthenticated, on_failure: { SessionController, :unauthenticated_api }
  plug Guardian.Plug.EnsurePermissions, on_failure: { SessionController, :forbidden_api }, default: [:write_profile]

  plug :action

  def index(conn, _params) do
    users = Repo.all(User)
    json(conn, %{ data: users, current_user: Guardian.Plug.current_resource(conn) })
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = User.update_changeset(user, user_params)

    if changeset.valid? do
      Repo.update(changeset)

      conn
      |> put_flash(:info, "User updated successfully.")
      |> redirect(to: user_path(conn, :index))
    else
      render(conn, "edit.html", user: user, changeset: changeset)
    end
  end
end
