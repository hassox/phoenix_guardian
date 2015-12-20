defmodule PhoenixGuardian.UserController do
  use PhoenixGuardian.Web, :controller
  use Guardian.Phoenix.Controller

  alias PhoenixGuardian.Repo
  alias PhoenixGuardian.User
  alias PhoenixGuardian.Authorization

  def new(conn, params, current_user, _claims) do
    render conn, "new.html", current_user: current_user
  end
end
