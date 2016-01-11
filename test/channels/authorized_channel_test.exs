defmodule PhoenixGuardian.AuthorizedChannelTest do
  use PhoenixGuardian.ChannelCase

  alias PhoenixGuardian.AuthorizedChannel
  import PhoenixGuardian.Factory

  setup do
    user = create(:user)
    {:ok, jwt, _} = Guardian.encode_and_sign(user)
    {:ok, _, socket} =
      socket()
    |> subscribe_and_join(AuthorizedChannel,
                          "authorized:lobby",
                          %{"guardian_token" => "#{jwt}"})

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{message: "pong"}
  end

  test "shout broadcasts to authorized:lobby", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all", from: "Bob Belcher"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  test "unauthenticated users cannot join" do
    assert {:error, %{error: "not authorized, are you logged in?"}} =
      socket()
      |> join(AuthorizedChannel, "authorized:lobby")
  end
end
