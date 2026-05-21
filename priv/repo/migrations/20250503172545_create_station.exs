defmodule EveIndustrex.Repo.Migrations.CreateStation do
  use Ecto.Migration

  def change do
    create table("stations", primary_key: false) do
      add :name, :string
      add :station_id, :bigint, primary_key: true
      add :services, {:array, :string}
      add :reprocessing_efficiency, :float
      add :reprocessing_stations_take, :float
      add :system_id, references(:systems, column: :system_id, type: :bigint), null: false

      timestamps()
    end
    create unique_index(:stations, [:station_id])
  end
end
