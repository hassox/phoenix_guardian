defmodule PhoenixGuardian.Api.V1.UserController do
  use PhoenixGuardian.Web, :controller

  alias PhoenixGuardian.User

  plug Guardian.Plug.EnsureSession, on_failure: { PhoenixGuardian.SessionController, :unauthenticated_api }

  plug :action

  def index(conn, _params) do
    users = Repo.all(User)
    json(conn, %{ data: users, current_user: Guardian.Plug.current_resource(conn) })
  end
end
