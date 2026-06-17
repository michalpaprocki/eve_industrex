defmodule EveIndustrex.Repo.Migrations.AlterMarketOrdersAddConstReg do
  use Ecto.Migration

  def change do
    alter table(:market_orders) do
      add :constellation_id, :integer
      add :region_id, :integer
    end
  end
end
