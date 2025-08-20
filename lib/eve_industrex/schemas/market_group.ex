defmodule EveIndustrex.Schemas.MarketGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_groups" do
    field :description, :string
    field :market_group_id, :integer
    field :name, :string
    field :parent_group_id, :integer
    has_many :types, EveIndustrex.Schemas.Type, foreign_key: :market_group_id, references: :market_group_id
    many_to_many :parent_market_group, EveIndustrex.Schemas.MarketGroup, join_through: "market_group_relationships", join_keys: [parent_id: :id, child_id: :id], preload_order: [asc: :name]
    many_to_many :child_market_group, EveIndustrex.Schemas.MarketGroup, join_through: "market_group_relationships", join_keys: [child_id: :id, parent_id: :id], preload_order: [asc: :name]
    timestamps(type: :utc_datetime)
  end

  def changeset(market_group, attrs) do
    market_group
    |> cast(attrs, [:description, :name, :parent_group_id, :market_group_id])
    |> unique_constraint(:market_group_id)
  end
end
