defmodule EveIndustrex.LoyaltyPoints.CorpOffer do

  use Ecto.Schema
  alias EveIndustrex.LoyaltyPoints.LpOffer
  alias EveIndustrex.LoyaltyPoints.NpcCorp
  @primary_key false
  schema "corps_offers" do
    belongs_to :corp, NpcCorp, foreign_key: :corp_id, references: :corp_id
    belongs_to :offer, LpOffer, foreign_key: :offer_id, references: :offer_id
  end

end
