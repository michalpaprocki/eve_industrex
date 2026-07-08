defmodule EveIndustrex.Industry.SystemCostIndex do
  use Ecto.Schema
  alias EveIndustrex.Universe.{Type, System}
  import Ecto.Changeset
  schema "system_cost_indices" do
    field :cost_index, :float
    field :activity, Ecto.Enum, values: [:copying, :invention, :manufacturing, :reaction, :researching_time_efficiency, :researching_material_efficiency]
    belongs_to :system, System, references: :system_id, foreign_key: :system_id

    timestamps(type: :utc_datetime)
  end

  def changeset(system_cost_index, attrs) do
    system_cost_index
    |> cast(attrs, [:cost_index, :activity, :type_id, :system_id])
  end
end
