defmodule EveIndustrex.Universe.Type do
  alias EveIndustrex.Industry.ReprocessMaterial
  alias EveIndustrex.LoyaltyPoints.LpOffer
  alias EveIndustrex.Market.AveragePrice
  alias EveIndustrex.Universe.MarketGroup

  alias EveIndustrex.Universe.Group

  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:type_id, :integer, autogenerate: false}
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
    field :volume, :float
    field :group_id, :integer
    field :market_group_id, :integer
    belongs_to :group, Group, references: :group_id, define_field: false, foreign_key: :group_id
    belongs_to :market_group, MarketGroup, references: :market_group_id, define_field: false, foreign_key: :market_group_id
    has_many :reprocess_materials, ReprocessMaterial, foreign_key: :source_type_id, references: :type_id
    has_many :lp_offers, LpOffer, foreign_key: :offer_id
    # optional blueprint products
    many_to_many :bp_products, __MODULE__, join_through: "bp_product_types", join_keys: [bp_product: :type_id, type: :type_id], on_delete: :delete_all, on_replace: :delete
    has_many :average_prices, AveragePrice, references: :type_id, foreign_key: :type_id, on_delete: :delete_all
    timestamps(type: :utc_datetime)
  end

  def changeset(type, attrs) do
    type
    |> cast(attrs, [:capacity, :description, :icon_id, :mass, :name, :packaged_volume, :portion_size, :published, :radius, :type_id, :volume, :group_id, :market_group_id ])
  end
end
