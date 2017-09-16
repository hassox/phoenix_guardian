defmodule PhoenixGuardianWeb.Controller.Helpers do
  import Plug.Conn

  def redirect_back(conn, alternative \\ "/") do
    path = conn
    |> get_req_header("referer")
    |> referrer
    path || alternative
  end

  defp referrer([]), do: nil
  defp referrer([h|_]), do: h
end

