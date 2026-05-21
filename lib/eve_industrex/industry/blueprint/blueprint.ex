defmodule EveIndustrex.Industry.Blueprint do
  use Ecto.Schema
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Industry.BlueprintActivity
  import Ecto.Changeset
  @primary_key {:blueprint_type_id, :integer, autogenerate: false}
  schema "blueprints" do
    field :max_production_limit, :integer
    has_many :activities, BlueprintActivity, references: :blueprint_type_id, foreign_key: :blueprint_type_id
    belongs_to :type, Type, references: :type_id, foreign_key: :blueprint_type_id, type: :integer, define_field: false
    timestamps(type: :utc_datetime)
  end

  def changeset(blueprint, attrs) do
    blueprint
    |> cast(attrs, [:blueprint_type_id, :max_production_limit])
  end
end
