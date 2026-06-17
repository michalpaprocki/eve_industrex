defmodule EveIndustrex.LoyaltyPoints.LpOffer.Store do

  def get_all(), do: :ets.tab2list(:lp_offers)
  def get_offer(offer_id) do
    :ets.lookup(:lp_offers, offer_id)
  end
end
