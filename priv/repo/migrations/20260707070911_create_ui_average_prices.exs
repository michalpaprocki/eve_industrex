defmodule EveIndustrex.Repo.Migrations.CreateUiAveragePrices do
  use Ecto.Migration

  def change do
    create unique_index(:average_prices, [:type_id])
  end
end
