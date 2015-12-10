defmodule PhoenixGuardian.AuthorizationTest do
  use PhoenixGuardian.ModelCase

  alias PhoenixGuardian.Authorization

  @valid_attrs %{provider: "some content", uid: "some content", user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Authorization.changeset(%Authorization{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Authorization.changeset(%Authorization{}, @invalid_attrs)
    refute changeset.valid?
  end
end
