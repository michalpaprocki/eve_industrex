defmodule EveIndustrex.Repo.Migrations.AlterMarketOrder do
  use Ecto.Migration

  def change do
    alter table("market_orders") do
      add :station_id, references(:stations, column: :station_id, type: :bigint), null: true
    end
  end
end
