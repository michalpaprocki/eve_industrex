defmodule EveIndustrex.Universe.Constellation do

  use Ecto.Schema
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Universe.Region
  import Ecto.Changeset

  @primary_key {:constellation_id, :integer, autogenerate: false}
  schema "constellations" do

    field :name, :string
    field :region_id, :integer
    has_many :systems, System, references: :constellation_id, foreign_key: :constellation_id
    belongs_to :region, Region, references: :region_id, define_field: false, foreign_key: :region_id


    timestamps(type: :utc_datetime)
  end

  def changeset(constellation, attrs) do
    constellation
    |> cast(attrs, [:name, :constellation_id, :region_id])
    |> unique_constraint([:name, :constellation_id])
    |> validate_required([:constellation_id, :name])
  end
end
