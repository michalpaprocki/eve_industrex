defmodule EveIndustrex.Schemas.TqVersion do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "tq_versions" do
    field :version, :string
    timestamps()
  end
  def changeset(tq_version, attrs) do
    tq_version
    |> cast(attrs, [:version])
  end
end
