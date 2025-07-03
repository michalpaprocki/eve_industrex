defmodule EveIndustrex.Schemas.NpcCorp do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "npc_corps" do
    field :name, :string
    field :corp_id, :integer
    many_to_many :offers, EveIndustrex.Schemas.LpOffer, join_through: "corps_offers", join_keys: [corp_id: :corp_id, offer_id: :offer_id]
  end

  def changeset(npc_corp, attrs) do
    npc_corp
    |> cast(attrs, [:name, :corp_id])
  end
end
