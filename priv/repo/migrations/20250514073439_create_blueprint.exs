defmodule EveIndustrex.Repo.Migrations.CreateBlueprint do
  use Ecto.Migration

  def change do

    create table("blueprints", primary_key: false) do
      add :blueprint_type_id, :bigint, primary_key: true
      add :max_production_limit, :bigint
      timestamps()
    end
  end
end
