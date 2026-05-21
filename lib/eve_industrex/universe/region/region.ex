defmodule EveIndustrex.Universe.Region do
  use Ecto.Schema
  alias EveIndustrex.Universe.Constellation
  import Ecto.Changeset
  @primary_key {:region_id, :integer, autogenerate: false}

  schema "regions" do
    field :name, :string
    field :description, :string
    has_many :constellations, Constellation, foreign_key: :region_id

    timestamps(type: :utc_datetime)
  end

  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name, :region_id, :description])
    |> unique_constraint([:name, :region_id])
    |> validate_required([:region_id, :name])
  end
end
