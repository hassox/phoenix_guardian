defmodule PhoenixGuardian.UsersChannel do
  use Phoenix.Channel
  use Guardian.Channel

  def join(_room, %{ claims: claims, resource: resource }, socket) do
    { :ok, %{ message: "Joined" }, socket }
  end

  def join(room, _, socket) do
    { :error,  :authentication_required }
  end

  def handle_in("ping", _payload, socket) do
    user = Guardian.Channel.current_resource(socket)
    broadcast socket, "pong", %{ message: "pong", from: user.email }
    { :noreply, socket }
  end
end
