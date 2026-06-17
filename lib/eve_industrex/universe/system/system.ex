defmodule EveIndustrex.Universe.System do

  use Ecto.Schema
  alias EveIndustrex.Market.MarketOrder
  alias EveIndustrex.Universe.{Constellation, Station}
  import Ecto.Changeset

  @primary_key {:system_id, :integer, autogenerate: false}
  schema "systems" do
    field :name, :string
    field :security_status, :float
    field :constellation_id, :integer
    belongs_to :constellation, Constellation, references: :constellation_id, define_field: false, foreign_key: :constellation_id
    has_many :stations, Station, foreign_key: :system_id
    has_many :market_orders, MarketOrder


    timestamps(type: :utc_datetime)
  end
  def changeset(system, attrs) do
    system
    |> cast(attrs, [:name, :system_id, :stations, :constellation_id, :security_status])
    |> unique_constraint([:system_id])
    |> validate_required([:system_id])
  end

end
