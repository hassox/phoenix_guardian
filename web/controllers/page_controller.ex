defmodule PhoenixGuardian.PageController do
  use PhoenixGuardian.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
