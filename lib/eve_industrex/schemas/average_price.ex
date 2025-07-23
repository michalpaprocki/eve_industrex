defmodule EveIndustrex.Schemas.AveragePrice do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "average_prices" do
    field :adjusted_price, :float
    field :average_price, :float
    field :type_id, :integer
    belongs_to :type, EveIndustrex.Schemas.Type, references: :type_id, foreign_key: :type_id, define_field: false

    timestamps()
  end
  def changeset(average_price, attrs) do
    average_price
    |> cast(attrs, [:adjusted_price, :average_price, :type_id])
    |> foreign_key_constraint(:type_id)
  end
end
