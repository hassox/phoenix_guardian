defmodule PhoenixGuardian.Repo.Migrations.CreateAuthorization do
  use Ecto.Migration

  def change do
    create table(:authorizations) do
      add :provider, :string
      add :uid, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :token, :string
      add :refresh_token, :string
      add :expires_at, :bigint

      timestamps
    end

    create index(:authorizations, [:provider, :uid], unique: true)
    create index(:authorizations, [:expires_at])
    create index(:authorizations, [:provider, :token])
  end
end
