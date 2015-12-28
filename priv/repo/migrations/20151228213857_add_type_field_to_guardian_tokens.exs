defmodule PhoenixGuardian.Repo.Migrations.AddTypeFieldToGuardianTokens do
  use Ecto.Migration

  def change do
    alter table(:guardian_tokens) do
      add :typ, :string
    end

    create index(:guardian_tokens, [:typ])
  end
end
