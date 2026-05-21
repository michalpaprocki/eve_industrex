defmodule EveIndustrex.Industry.BlueprintActivitySkill do
  use Ecto.Schema
  alias EveIndustrex.Universe.Type
  schema "blueprint_activity_skills" do
    field :level, :integer
    field :type_id, :integer
    field :blueprint_type_id, :integer
    field :activity_type, Ecto.Enum, values: [:copying, :invention, :manufacturing, :reaction, :research_material, :research_time]
    belongs_to :type, Type, references: :type_id, foreign_key: :type_id, define_field: false


    timestamps(type: :utc_datetime)
  end

end
