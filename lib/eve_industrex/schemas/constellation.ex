defmodule EveIndustrex.Schemas.Constellation do
  use Ecto.Schema
  alias EveIndustrex.Schemas.{Region, System}
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "constellations" do
    field :constellation_id, :integer
    field :name, :string
    field :region_id, :integer
    has_many :systems, System
    belongs_to :region, Region, references: :region_id, define_field: false


    timestamps(type: :utc_datetime)
  end

  def changeset(constellation, attrs) do
    constellation
    |> cast(attrs, [:name, :constellation_id])
    |> unique_constraint([:name, :constellation_id])
    |> validate_required([:constellation_id, :name])
  end
end
