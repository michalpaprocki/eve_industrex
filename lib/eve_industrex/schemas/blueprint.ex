defmodule EveIndustrex.Schemas.Blueprint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "blueprints" do
    field :blueprintTypeID, :integer
    field :maxProductionLimit, :integer
    field :activities, :binary

  end

  def changeset(blueprint, attrs) do
    blueprint
    |> cast(attrs, [:blueprintTypeID, :maxProductionLimit, :activities])
    |> unique_constraint(:blueprintTypeID)
  end
end
