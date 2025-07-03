defmodule EveIndustrex.Repo.Migrations.CreateMarketOrder do
  use Ecto.Migration

  def change do
    create table("market_orders", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :duration, :integer
      add :is_buy_order, :boolean
      add :issued, :string
      add :location_id, :bigint
      add :min_volume, :bigint
      add :order_id, :bigint
      add :price, :float
      add :range, :string
      add :type_id, :bigint
      add :volume_remain, :bigint
      add :volume_total, :bigint
      add :system_id, :bigint

      timestamps()

    end
  end
end
