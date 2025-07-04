defmodule EveIndustrex.Schemas.BlueprintActivity do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "blueprint_activities" do
    field :activity_type, Ecto.Enum, values: [:copying, :invention, :manufacturing, :reaction, :research_material, :research_time]
    field :time, :integer
    has_many :materials, EveIndustrex.Schemas.Material
    has_many :products, EveIndustrex.Schemas.BlueprintProduct
    field :probability, :float
    field :blueprint_type_id, :integer
    belongs_to :blueprint, EveIndustrex.Schemas.Blueprint, references: :blueprint_type_id, define_field: false, foreign_key: :blueprint_type_id
  end
  def changeset(blueprint_activity, attrs) do
    blueprint_activity
    |> cast(attrs, [:activity_type, :time, :probability, :blueprint_type_id])
    |> cast_assoc(:materials)
    |> cast_assoc(:products)
  end
# add skills later on
end
