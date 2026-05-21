defmodule EveIndustrex.Repo.Migrations.CreateConstellation do
  use Ecto.Migration

  def change do
    create table("constellations", primary_key: false) do
      add :name, :string
      add :constellation_id, :bigint, primary_key: true
      add :region_id, references(:regions, column: :region_id, type: :bigint), null: false
      timestamps()
    end

    create unique_index(:constellations, [:constellation_id])

  end
end
