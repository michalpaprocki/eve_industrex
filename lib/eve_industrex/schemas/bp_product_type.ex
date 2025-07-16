defmodule EveIndustrex.Schemas.BpProductType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bp_product_types" do
    field :bp_product, :integer
    field :type, :integer
  end
  def changeset(bp_product_type, attrs) do
    bp_product_type
    |> cast(attrs, [:bp_product, :type])
  end
end
