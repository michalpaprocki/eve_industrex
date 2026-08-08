defmodule EveIndustrex.LoyaltyPoints.CorpOffer.Store do
  @moduledoc false
  def get_corp_offer(corp_id) do
    :ets.lookup(:corp_offers, corp_id)
  end

  def get_all() do
    :ets.tab2list(:corp_offers)
  end
end
