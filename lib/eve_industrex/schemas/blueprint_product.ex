defmodule EveIndustrex.Schemas.BlueprintProduct do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "blueprint_products" do
    field :amount, :integer
    field :product_type_id, :integer
    field :blueprint_activity_id, :binary_id
    has_one :product, EveIndustrex.Schemas.Type, foreign_key: :type_id, references: :product_type_id
    belongs_to :blueprint_activity, EveIndustrex.Schemas.BlueprintActivity, define_field: false

  end
  def changeset(blueprint_product, attrs) do
    blueprint_product
    |> cast(attrs, [:amount, :product_type_id, :blueprint_activity_id])
  end
end
