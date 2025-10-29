defmodule EveIndustrex.Repo.Migrations.AlterMasrketStatisticsPriceTypes do
  use Ecto.Migration

  def change do
    alter table("market_statistics") do
      modify :average, :float, from: :bigint
      modify :highest, :float, from: :bigint
      modify :lowest, :float, from: :bigint
      modify :date, :date, from: :utc_datetime
    end
    create unique_index(:market_statistics, [:date, :type_id, :region_id], name: :unique_date_type_region)
  end
end
