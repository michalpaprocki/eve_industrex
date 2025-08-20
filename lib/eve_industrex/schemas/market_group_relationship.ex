defmodule EveIndustrex.Schemas.MarketGroupRelationship do
  use Ecto.Schema

  schema "market_group_relationships"  do
    field :parent_id, :binary_id
    field :child_id, :binary_id
  end

end
