defmodule PhoenixGuardian.Factory do
  use ExMachina.Ecto, repo: PhoenixGuardian.Repo

  alias PhoenixGuardian.User
  alias PhoenixGuardian.Authorization
  alias PhoenixGuardian.GuardianToken

  def user_factory do
    %User{
      name: "Bob Belcher",
      email: sequence(:email, &"email-#{&1}@example.com"),
    }
  end

  def guardian_token_factory do
    %GuardianToken{
      jti: sequence(:jti, &"jti-#{&1}"),
    }
  end

  def authorization_factory do
    %Authorization{
      uid: sequence(:uid, &"uid-#{&1}"),
      user: build(:user),
      provider: "identity",
      token: Comeonin.Bcrypt.hashpwsalt("sekrit")
    }
  end

  def with_authorization(user, opts \\ []) do
    opts = opts ++ [user: user, uid: user.email]
    insert(:authorization, opts)
  end
end
