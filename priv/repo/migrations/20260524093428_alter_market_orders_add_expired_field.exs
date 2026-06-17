defmodule EveIndustrex.Repo.Migrations.AlterMarketOrdersAddExpiredField do
  use Ecto.Migration

  def change do
    alter table("market_orders") do
      add :expired, :boolean
    end
  end
end
