defmodule EveIndustrex.Universe.Group do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Universe.Category

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:group_id, :integer, autogenerate: false}
  schema "groups" do
    field :category_id, :integer
    field :name, :string
    field :published, :boolean
    belongs_to :category, Category, foreign_key: :category_id, references: :category_id, define_field: false
    has_many :types, Type, foreign_key: :group_id, references: :group_id
  end
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:category_id, :group_id, :name, :published])
  end
end
