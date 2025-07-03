defmodule EveIndustrex.Schemas.MarketOrder do
  alias EveIndustrex.Schemas.Station
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}

  schema "market_orders" do
    field :duration, :integer
    field :is_buy_order, :boolean
    field :issued, :string
    field :min_volume, :integer
    field :order_id, :integer
    field :price, :float
    field :range, :string
    field :type_id, :integer
    field :volume_remain, :integer
    field :volume_total, :integer
    field :location_id, :integer
    field :station_id, :integer
    field :system_id, :integer
    belongs_to :station, Station, references: :station_id, define_field: false

    timestamps(type: :utc_datetime)
  end

  def changeset(market_order, attrs) do
    market_order
    |> cast(attrs, [:duration, :is_buy_order, :issued, :location_id, :min_volume, :order_id, :price, :range, :system_id, :type_id, :volume_remain, :volume_total])
    |> unique_constraint(:order_id, name: :market_orders_order_id_index)
  end
end
