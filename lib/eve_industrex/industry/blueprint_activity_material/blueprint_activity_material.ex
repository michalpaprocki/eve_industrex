defmodule EveIndustrex.Industry.BlueprintActivityMaterial do
  use Ecto.Schema


  schema "blueprint_activity_materials" do
    field :blueprint_type_id, :integer
    field :quantity, :integer
    field :type_id, :integer
    field :activity_type, Ecto.Enum, values: [:copying, :invention, :manufacturing, :reaction, :research_material, :research_time]

    timestamps(type: :utc_datetime)
  end

end
