defmodule PhoenixGuardian.UserTest do
  use PhoenixGuardian.ModelCase

  alias PhoenixGuardian.User

  @valid_attrs %{email: "some content", password: "some contest", encrypted_password: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.create_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.create_changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
