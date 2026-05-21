defmodule EveIndustrex.Industry.ReprocessMaterial do
  use Ecto.Schema
  alias  EveIndustrex.Universe.Type
  schema "reprocess_materials" do
    belongs_to :source_type, Type, references: :type_id, foreign_key: :source_type_id, type: :integer, define_field: false
    belongs_to :material_type, Type, references: :type_id, foreign_key: :material_type_id, type: :integer, define_field: false
    field :source_type_id, :integer
    field :material_type_id, :integer
    field :quantity, :integer
    field :quantity_max, :integer
    field :quantity_min, :integer
    timestamps(type: :utc_datetime)
  end

end
