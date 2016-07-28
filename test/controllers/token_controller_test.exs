defmodule PhoenixGuardian.TokenControllerTest do
  use PhoenixGuardian.ConnCase

  import PhoenixGuardian.Factory

  alias PhoenixGuardian.Repo
  alias PhoenixGuardian.GuardianToken

  setup do
    {:ok, %{user: insert(:user)}}
  end

  test "GET /tokens without permission", %{ user: user } do
    conn = guardian_login(user)
      |> get("/tokens")

    assert html_response(conn, 302)
  end

  test "GET /tokens with permission", %{ user: user } do
    conn = guardian_login(user, :access, perms: %{default: [:read_token]})
      |> get("/tokens")

    assert html_response(conn, 200)
  end

  test "DELETE /tokens/:jti with no login should fail" do
    token = insert(:guardian_token)
    conn = build_conn()
    conn = delete conn, token_path(conn, :delete, token.jti)

    assert html_response(conn, 302)
    assert Repo.get(GuardianToken, token.jti).jti == token.jti
  end

  test "DELETE /tokens/:jti without revoke permission should fail", %{user: user} do
    token = insert(:guardian_token)
    conn = guardian_login(user, :access)
      |> delete(token_path(build_conn(), :delete, token.jti))

    assert html_response(conn, 302)

    new_token = Repo.get(GuardianToken, token.jti)
    refute new_token == nil
    assert new_token.jti == token.jti
  end

  test "DELETE /tokens/:jti without revoke permission should be cool", %{user: user} do
    token = insert(:guardian_token)
    guardian_login(user, :access, perms: %{default: [:revoke_token]})
      |> delete(token_path(build_conn(), :delete, token.jti))

    new_token = Repo.get(GuardianToken, token.jti)
    assert new_token == nil
  end
end
