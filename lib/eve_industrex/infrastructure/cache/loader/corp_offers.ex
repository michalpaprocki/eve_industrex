defmodule EveIndustrex.Infrastructure.Cache.Loader.CorpOffers do
  alias EveIndustrex.LoyaltyPoints
  @moduledoc false
  def init() do
    corp_offers =
      LoyaltyPoints.NpcCorp.Store.get_all()
      |> Enum.map(fn x -> LoyaltyPoints.CorpOffer.Query.get_corp_offers_for_cache(elem(x, 0)) end)

    :ets.insert(:corp_offers, corp_offers)
  end
end
