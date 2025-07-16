defmodule EveIndustrex.Schemas.LpOffer do
  use Ecto.Schema
  import Ecto.Changeset
  alias EveIndustrex.Schemas.{NpcCorp, LpReqItem, Type}
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "lp_offers" do
    field :isk_cost, :integer
    field :lp_cost, :integer
    field :quantity, :integer
    field :type_id, :integer
    field :offer_id, :integer
    belongs_to :type, Type, references: :type_id, define_field: false
    many_to_many :corps, NpcCorp, join_through: "corps_offers", join_keys: [offer_id: :offer_id, corp_id: :corp_id]
    has_many :req_items, LpReqItem, foreign_key: :offer_id, references: :offer_id
  end
  def changeset(lp_offer, attrs) do
    lp_offer
    |> cast(attrs, [:isk_cost, :lp_cost, :quantity, :type_id, :offer_id])
    |> unique_constraint(:offer_id)

  end

end
