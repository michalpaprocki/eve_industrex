defmodule EveIndustrex.Repo.Migrations.MarketStatisticsAddRegionRelation do
  use Ecto.Migration

  def change do
    alter table("market_statistics") do
      add :region_id, references(:regions, column: :region_id, type: :bigint)
    end
  end
end
