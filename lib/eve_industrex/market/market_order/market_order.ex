defmodule EveIndustrex.Market.MarketOrder do

  alias EveIndustrex.Universe.Station
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:order_id, :integer, autogenerate: false}
  schema "market_orders" do
    field :duration, :integer
    field :is_buy_order, :boolean
    field :issued, :utc_datetime
    field :min_volume, :integer
    field :price, :float
    field :range, :string
    field :type_id, :integer
    field :volume_remain, :integer
    field :volume_total, :integer
    field :location_id, :integer
    field :station_id, :integer
    field :system_id, :integer
    field :constellation_id, :integer
    field :region_id, :integer
    field :expired, :boolean, default: false
    field :generation, :integer, default: 1
    belongs_to :station, Station, references: :station_id, define_field: false

    timestamps(type: :utc_datetime)
  end

  def changeset(market_order, attrs) do
    market_order
    |> cast(attrs, [:duration, :is_buy_order, :issued, :location_id, :min_volume, :order_id, :price, :range, :station_id, :system_id, :type_id, :volume_remain, :volume_total, :region_id, :generation])
    |> unique_constraint(:order_id, name: :market_orders_order_id_index)
  end
end
