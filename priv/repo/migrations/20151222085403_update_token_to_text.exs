defmodule PhoenixGuardian.Repo.Migrations.UpdateTokenToText do
  use Ecto.Migration

  def change do
    alter table(:authorizations) do
      modify :token, :text
      modify :refresh_token, :text
    end
  end
end
