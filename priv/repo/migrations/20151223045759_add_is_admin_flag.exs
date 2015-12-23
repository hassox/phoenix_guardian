defmodule PhoenixGuardian.Repo.Migrations.AddIsAdminFlag do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_admin, :boolean, default: false
    end
  end
end
