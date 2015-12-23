defmodule PhoenixGuardian.UserControllerTest do
  use PhoenixGuardian.ConnCase
  import PhoenixGuardian.Factory

  setup do
    {:ok, %{user1: create(:user), user2: create(:user)}}
  end

  test "GET /admin/users without login" do
    conn = conn()
    conn = get conn, admin_user_path(conn, :index)
    assert html_response(conn, 302)
  end

  test "GET /admin/users without admin login", %{user1: user} do
    conn = guardian_login(user)
    conn = get conn, admin_user_path(conn, :index)
    assert html_response(conn, 302)
  end

  test "GET /admin/users with no admin logged in as an admin", %{user1: user1, user2: user2} do
    conn = guardian_login(user1, :token, key: :admin)
    conn = get conn, admin_user_path(conn, :index)
    assert html_response(conn, 200)
    assert conn.resp_body =~ user1.email
    assert conn.resp_body =~ user2.email
  end
end

