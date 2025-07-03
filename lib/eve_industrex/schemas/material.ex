defmodule EveIndustrex.Schemas.Material do
  use Ecto.Schema
  alias EveIndustrex.Schemas.Type
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "materials" do
    field :materials, :binary
    field :type_id, :integer
    belongs_to :type, Type, references: :type_id, define_field: false
  end

   def changeset(material, attrs) do
    material
    |> cast(attrs, [:materials, :type_id])
    |> unique_constraint(:type_id)
  end
end
