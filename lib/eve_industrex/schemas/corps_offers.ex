defmodule EveIndustrex.Schemas.CorpsOffers do
  use Ecto.Schema

  @primary_key false
  schema "corps_offers" do
    belongs_to :corp, EveIndustrex.Schemas.NpcCorp, foreign_key: :corp_id
    belongs_to :offer, EveIndustrex.Schemas.LpOffer, foreign_key: :offer_id
  end

end
