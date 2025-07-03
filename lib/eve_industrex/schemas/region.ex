defmodule EveIndustrex.Schemas.Region do
  use Ecto.Schema
  alias EveIndustrex.Schemas.{Constellation}
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "regions" do
    field :name, :string
    field :region_id, :integer
    has_many :constellations, Constellation, foreign_key: :region_id

    timestamps(type: :utc_datetime)
  end

  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name, :region_id])
    |> unique_constraint([:name, :region_id])
    |> validate_required([:region_id, :name])
  end
end
