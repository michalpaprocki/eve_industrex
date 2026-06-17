defmodule EveIndustrex.Repo.Migrations.AlterMarketOrdersAddGeneration do
  use Ecto.Migration

  def change do
    alter table(:market_orders) do
      add :generation, :integer
    end
  end
end
