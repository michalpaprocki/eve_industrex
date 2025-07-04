defmodule EveIndustrex.Repo.Migrations.AlterBlueprint do
  use Ecto.Migration

  def change do
    rename table("blueprints"), :blueprintTypeID, to: :blueprint_type_id
    rename table("blueprints"), :maxProductionLimit, to: :max_production_limit
    alter table("blueprints") do
      remove :activities
    end
  end
end
