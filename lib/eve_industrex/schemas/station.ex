defmodule EveIndustrex.Schemas.Station do
  use Ecto.Schema
  alias EveIndustrex.Schemas.{MarketOrder, System}
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "stations" do
    field :name, :string
    field :station_id, :integer
    field :system_id, :integer
    field :services, {:array, :string}
    field :reprocessing_efficiency, :float
    field :reprocessing_stations_take, :float
    belongs_to :system, System, references: :system_id, define_field: false, foreign_key: :system_id
    has_many :market_orders, MarketOrder, foreign_key: :order_id
    timestamps(type: :utc_datetime)
  end
  def changeset(station, attrs) do
    station
    |> cast(attrs, [:name, :station_id, :system_id, :services, :reprocessing_efficiency, :reprocessing_stations_take])
  end
end
