defmodule EveIndustrex.Schemas.Blueprint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "blueprints" do
    field :blueprint_type_id, :integer
    field :max_production_limit, :integer
    has_many :activities, EveIndustrex.Schemas.BlueprintActivity, references: :blueprint_type_id, foreign_key: :blueprint_type_id

  end

  def changeset(blueprint, attrs) do
    blueprint
    |> cast(attrs, [:blueprint_type_id, :max_production_limit])
    |> cast_assoc(:activities)
    |> unique_constraint(:blueprint_type_id)
  end
end
