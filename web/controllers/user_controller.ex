defmodule PhoenixGuardian.UserController do
  use PhoenixGuardian.Web, :controller

  def new(conn, _params, current_user, _claims) do
    render conn, "new.html", current_user: current_user
  end
end
