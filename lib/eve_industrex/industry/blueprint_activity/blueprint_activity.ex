defmodule EveIndustrex.Industry.BlueprintActivity do

  use Ecto.Schema
  import Ecto.Changeset

  alias EveIndustrex.Industry.Blueprint
  schema "blueprint_activities" do
    field :activity_type, Ecto.Enum, values: [:copying, :invention, :manufacturing, :reaction, :research_material, :research_time]
    field :time, :integer
    field :blueprint_type_id, :integer
    belongs_to :blueprint, Blueprint, references: :blueprint_type_id, define_field: false, foreign_key: :blueprint_type_id, type: :integer
    has_many :materials, EveIndustrex.Industry.BlueprintActivityMaterial, references: :blueprint_type_id, foreign_key: :blueprint_type_id
    has_many :products, EveIndustrex.Industry.BlueprintActivityProduct, references: :blueprint_type_id, foreign_key: :blueprint_type_id
    timestamps(type: :utc_datetime)
  end
  def changeset(blueprint_activity, attrs) do
    blueprint_activity
    |> cast(attrs, [:activity_type, :time, :blueprint_type_id])
    |> cast_assoc(:materials)
    |> cast_assoc(:products)
  end
# add skills later on
end
