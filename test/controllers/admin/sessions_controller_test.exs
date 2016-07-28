defmodule PhoenixGuardian.SessionControllerTest do
  use PhoenixGuardian.ConnCase

  import PhoenixGuardian.Factory

  alias PhoenixGuardian.User

  setup do
    auth = insert(:user)|> User.make_admin! |> with_authorization
    {:ok, %{user: auth.user}}
  end

  test "/GET login when not logged in as admin" do
    conn = build_conn()
    conn = get conn, admin_login_path(conn, :new)
    assert html_response(conn, 200)
  end

  test "/GET login when logged in as a normal user", %{user: user} do
    conn = guardian_login(user)
    conn = get conn, admin_login_path(conn, :new)
    assert html_response(conn, 200)
  end

  test "/POST login when not logged in", %{user: user} do
    conn = build_conn()
    |> post(admin_session_path(build_conn(), :callback, "identity"), email: user.email, password: "sekrit")

    assert html_response(conn, 302)
    assert Guardian.Plug.current_resource(conn, :admin).id == user.id
    assert Guardian.Plug.current_resource(conn) == nil
  end

  test "DELETE logout when logged in", %{user: user} do
    conn = guardian_login(user, :token, key: :admin)
      |> bypass_through(PhoenixGuardian.Router, [:browser, :admin_browser_auth])
      |> get("/")

    refute Guardian.Plug.current_resource(conn, :admin) == nil
    assert Guardian.Plug.current_resource(conn, :admin).id == user.id

    conn = delete recycle(conn), admin_logout_path(conn, :logout)
    assert Guardian.Plug.current_resource(conn, :admin) == nil
  end
end
