defmodule PhoenixGuardianWeb.PageController do
  use PhoenixGuardianWeb, :controller

  def index(conn, _params, current_user, _claims) do
    render conn, "index.html", current_user: current_user
  end
end
