defmodule PhoenixGuardian.PageController do
  use PhoenixGuardian.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
