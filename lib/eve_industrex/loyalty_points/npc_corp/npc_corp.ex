defmodule EveIndustrex.LoyaltyPoints.NpcCorp do
  alias EveIndustrex.LoyaltyPoints.LpOffer
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:corp_id, :integer, autogenerate: false}
  schema "npc_corps" do
    field :name, :string

    field :description, :string
    many_to_many :offers, LpOffer, join_through: "corps_offers", join_keys: [corp_id: :corp_id, offer_id: :offer_id]
    timestamps(type: :utc_datetime)
  end

  def changeset(npc_corp, attrs) do
    npc_corp
    |> cast(attrs, [:name, :corp_id, :description])
  end
end
