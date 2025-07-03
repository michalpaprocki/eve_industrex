defmodule EveIndustrex.Repo.Migrations.CreateRegion do
  use Ecto.Migration

  def change do
    create table("regions", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :region_id, :bigint
      add :name, :string
      add :constellations, {:array, :bigint}

      timestamps()
    end
    create unique_index(:regions, [:region_id])
  end
end
