defmodule EveIndustrex.Repo.Migrations.AlterResourceTypes do
  use Ecto.Migration

  def change do
    alter table(:resource_types) do
      add :strategies_count, :integer
    end
  end
end
