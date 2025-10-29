defmodule EveIndustrex.Repo.Migrations.CreateMarketStatistics do
  use Ecto.Migration

  def change do
    create table("market_statistics", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :average, :bigint
      add :date, :utc_datetime
      add :highest, :bigint
      add :lowest, :bigint
      add :order_count, :bigint
      add :volume, :bigint
      add :type_id, references(:types, column: :type_id, type: :bigint)

    timestamps(type: :utc_datetime)

    end
  end
end
