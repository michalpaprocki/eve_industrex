defmodule EveIndustrex.LoyaltyPoints.CorpOffer.Store do

  def get_corp_offer(corp_id) do
    :ets.lookup(:corp_offers, corp_id)
  end
end
