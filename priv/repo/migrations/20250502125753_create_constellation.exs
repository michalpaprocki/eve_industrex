defmodule EveIndustrex.Repo.Migrations.CreateConstellation do
  use Ecto.Migration

  def change do
    create table("constellations", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :constellation_id, :bigint
      add :region_id, references(:regions, column: :region_id, type: :bigint), null: false
      timestamps()
    end

    create unique_index(:constellations, [:constellation_id])

  end
end
