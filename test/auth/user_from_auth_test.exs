defmodule PhoenixGuardian.UserFromAuthTest do
  use PhoenixGuardian.ModelCase

  import Ecto.Query

  alias PhoenixGuardian.Repo
  alias PhoenixGuardian.User
  alias PhoenixGuardian.Authorization
  alias PhoenixGuardian.UserFromAuth
  alias Ueberauth.Auth
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Info

  @name "Daniel Neighman"
  @email "has.sox@gmail.com"
  @uid "hassox"
  @provider :github
  @token "the-token"
  @refresh_token "refresh-token"

  setup do
    auth = %Auth{
      uid: @uid,
      provider: @provider,
      info: %Info{
        name: @name,
        email: @email,
      },
      credentials: %Credentials{
        token: @token,
        refresh_token: "refresh-token",
        expires_at: Guardian.Utils.timestamp + 1000,
      }
    }
  {:ok, %{auth: auth, repo: Repo}}
  end

  def user_count, do: Repo.one(from u in User, select: count(u.id))
  def authorization_count, do: Repo.one(from a in Authorization, select: count(a.id))

  test "it creates a new authorization and user when there is neither", %{auth: auth} do
    before_users = user_count
    before_authorizations = authorization_count
    {:ok, user} = UserFromAuth.get_or_insert(auth, nil, Repo)
    after_users = user_count
    after_authorizations = authorization_count

    assert after_users == (before_users + 1)
    assert after_authorizations == (before_authorizations + 1)
    assert user.email == @email
  end

  test "it returns the existing user when the authorization and user both exist", %{auth: auth} do
    {:ok, user} = User.registration_changeset(%User{}, %{email: @email, name: @name}) |> Repo.insert
    {:ok, _authorization} = Authorization.changeset(
      Ecto.Model.build(user, :authorizations),
      %{
        provider: to_string(@provider),
        uid: @uid,
        token: @token,
        refresh_token: @refresh_token,
        expires_at: Guardian.Utils.timestamp + 500
      }
    ) |> Repo.insert

    before_users = user_count
    before_authorizations = authorization_count
    {:ok, user_from_auth} = UserFromAuth.get_or_insert(auth, nil, Repo)
    assert user_from_auth.id == user.id

    assert user_count == before_users
    assert authorization_count == before_authorizations
  end

  test "it returns an existing user when the user has the same email", %{auth: auth} do
    {:ok, user} = User.registration_changeset(%User{}, %{email: @email, name: @name}) |> Repo.insert
    before_users = user_count
    before_authorizations = authorization_count
    {:ok, user_from_auth} = UserFromAuth.get_or_insert(auth, nil, Repo)
    assert user_from_auth.id == user.id

    assert user_count == before_users
    assert authorization_count == before_authorizations + 1
  end

  test "it deletes the authorization and makes a new one when the old one is expired", %{auth: auth} do
    {:ok, user} = User.registration_changeset(%User{}, %{email: @email, name: @name}) |> Repo.insert
    {:ok, authorization} = Authorization.changeset(
      Ecto.Model.build(user, :authorizations),
      %{
        provider: to_string(@provider),
        uid: @uid,
        token: @token,
        refresh_token: @refresh_token,
        expires_at: Guardian.Utils.timestamp - 500
      }
    ) |> Repo.insert

    before_users = user_count
    before_authorizations = authorization_count
    {:ok, user_from_auth} = UserFromAuth.get_or_insert(auth, nil, Repo)

    assert user_from_auth.id == user.id
    assert before_users == user_count
    assert authorization_count == before_authorizations
    auth2 = Repo.one(Ecto.Model.assoc(user, :authorizations))
    refute auth2.id == authorization.id
  end

  test "it returns an error if the user is not the current user", %{auth: auth} do
    {:ok, current_user} = User.registration_changeset(%User{}, %{email: "fred@example.com", name: @name}) |> Repo.insert
    {:ok, user} = User.registration_changeset(%User{}, %{email: @email, name: @name}) |> Repo.insert
    {:ok, _authorization} = Authorization.changeset(
      Ecto.Model.build(user, :authorizations),
      %{
        provider: to_string(@provider),
        uid: @uid,
        token: @token,
        refresh_token: @refresh_token,
        expires_at: Guardian.Utils.timestamp + 500
      }
    ) |> Repo.insert

    {:error, :user_does_not_match} = UserFromAuth.get_or_insert(auth, current_user, Repo)
  end
end

