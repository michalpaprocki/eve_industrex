defmodule EveIndustrex.Repo.Migrations.CreateBlueprint do
  use Ecto.Migration

  def change do

    create table("blueprints", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :blueprintTypeID, :bigint
      add :maxProductionLimit, :bigint
      add :activities, :binary
    end
    create unique_index(:blueprints, [:blueprintTypeID])
  end
end
