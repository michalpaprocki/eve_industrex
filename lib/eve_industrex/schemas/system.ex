defmodule EveIndustrex.Schemas.System do
  use Ecto.Schema
  alias EveIndustrex.Schemas.{MarketOrder, Constellation}
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "systems" do
    field :system_id, :integer
    field :name, :string
    field :stations, {:array, :integer}
    field :security_status, :float
    field :constellation_id, :integer
    belongs_to :constellation, Constellation, references: :constellation_id, define_field: false
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
