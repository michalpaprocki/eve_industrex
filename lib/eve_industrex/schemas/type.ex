defmodule EveIndustrex.Schemas.Type do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "types" do
    field :capacity, :float
    field :description, :string
    field :icon_id, :integer
    field :mass, :float
    field :name, :string
    field :packaged_volume, :float
    field :portion_size, :integer
    field :published, :boolean
    field :radius, :float
    field :type_id, :integer
    field :volume, :float
    field :group_id, :integer
    field :market_group_id, :integer
    belongs_to :market_group, EveIndustrex.Schemas.MarketGroup, references: :market_group_id, define_field: false
    has_many :lp_offers, EveIndustrex.Schemas.LpOffer, foreign_key: :offer_id
    # from reprocess
    has_many :products, EveIndustrex.Schemas.Material, references: :type_id, foreign_key: :product_type_id
    # for production
    has_many :materials, EveIndustrex.Schemas.Material, references: :type_id, foreign_key: :material_type_id
    # optional blueprint products
    many_to_many :bp_products, EveIndustrex.Schemas.Type, join_through: "bp_product_types", join_keys: [bp_product: :type_id, type: :type_id]

    timestamps(type: :utc_datetime)
  end

  def changeset(type, attrs) do
    type
    |> cast(attrs, [:capacity, :description, :icon_id, :mass, :name, :packaged_volume, :portion_size, :published, :radius, :type_id, :volume, :group_id, :market_group_id ])
  end
end
