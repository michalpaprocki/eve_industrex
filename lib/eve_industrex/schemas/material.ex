defmodule EveIndustrex.Schemas.Material do
  use Ecto.Schema
  alias EveIndustrex.Schemas.Type
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "materials" do
    field :material_type_id, :integer
    field :product_type_id, :integer
    field :amount, :integer
    field :blueprint_activity_id, :binary_id
    belongs_to :blueprint_activity, EveIndustrex.Schemas.BlueprintActivity, define_field: false
    belongs_to :material_type, Type, references: :type_id, define_field: false, foreign_key: :material_type_id
    belongs_to :product_type, Type, references: :type_id, define_field: false, foreign_key: :product_type_id
  end

   def changeset(material, attrs) do
    material
    |> cast(attrs, [:material_type_id, :product_type_id, :amount, :blueprint_activity_id])
  end
end
