defmodule EveIndustrex.Repo.Migrations.CreateRegion do
  use Ecto.Migration

  def change do
    create table("regions", primary_key: false) do
      add :region_id, :bigint, primary_key: true
      add :name, :string
      add :description, :text
      add :constellations, {:array, :bigint}

      timestamps()
    end
    create unique_index(:regions, [:region_id])
  end
end
