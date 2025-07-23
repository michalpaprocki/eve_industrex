defmodule EveIndustrex.Schemas.Group do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "groups" do
    field :category_id, :integer
    field :group_id, :integer
    field :name, :string
    field :published, :boolean
    belongs_to :category, EveIndustrex.Schemas.Category, foreign_key: :category_id, references: :category_id, define_field: false
    has_many :types, EveIndustrex.Schemas.Type, foreign_key: :group_id, references: :group_id
  end
  def changset(group, attrs) do
    group
    |> cast(attrs, [:category_id, :group_id, :name, :published])
  end
end
