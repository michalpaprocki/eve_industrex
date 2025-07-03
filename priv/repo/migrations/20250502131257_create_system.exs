defmodule EveIndustrex.Repo.Migrations.CreateSystem do
  use Ecto.Migration

  def change do
    create table("systems", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :system_id, :bigint
      add :stations, {:array, :bigint}
      add :constellation_id, references(:constellations, column: :constellation_id, type: :bigint), null: false

      timestamps()
    end

    create unique_index(:systems, [:system_id])
  end
end
