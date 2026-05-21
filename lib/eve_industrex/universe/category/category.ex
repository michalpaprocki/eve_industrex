defmodule EveIndustrex.Universe.Category do
  alias EveIndustrex.Universe.Group
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:category_id, :integer, autogenerate: false}
  schema "categories" do

    field :name, :string
    field :published, :boolean
    has_many :groups, Group, references: :category_id, foreign_key: :category_id

  end
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:category_id, :name, :published])
    |> validate_required([:category_id, :name, :published])
  end
end
