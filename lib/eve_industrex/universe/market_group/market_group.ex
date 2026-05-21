defmodule EveIndustrex.Universe.MarketGroup do

  use Ecto.Schema
  import Ecto.Changeset
  alias EveIndustrex.Universe.Type

  @primary_key {:market_group_id, :integer, autogenerate: false}
  schema "market_groups" do
    field :description, :string
    field :name, :string
    field :parent_group_id, :integer
    has_many :types, Type, foreign_key: :market_group_id, references: :market_group_id, preload_order: [asc: :name]
    belongs_to :parent_market_group, __MODULE__, foreign_key: :parent_group_id, references: :market_group_id, define_field: false, type: :integer
    has_many :child_market_group, __MODULE__, foreign_key: :parent_group_id, references: :market_group_id
    timestamps(type: :utc_datetime)
  end

  def changeset(market_group, attrs) do
    market_group
    |> cast(attrs, [:description, :name, :parent_group_id, :market_group_id])
    |> unique_constraint(:market_group_id)
  end
end
