defmodule PhoenixGuardian.PageController do
  use PhoenixGuardian.Web, :controller
  use Guardian.Phoenix.Controller
  alias PhoenixGuardian.Repo

  def index(conn, _params, current_user, _claims) do
    render conn, "index.html", current_user: current_user
  end

  def maybe_public(conn, _params, current_user, _claims) do
    render conn, "maybe_public.html", current_user: current_user
  end
end
