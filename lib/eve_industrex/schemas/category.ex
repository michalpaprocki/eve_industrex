defmodule EveIndustrex.Schemas.Category do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "categories" do
    field :category_id, :integer
    field :name, :string
    field :published, :boolean
    has_many :groups, EveIndustrex.Schemas.Group, references: :category_id, foreign_key: :category_id

  end
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:category_id, :name, :published])
  end
end
