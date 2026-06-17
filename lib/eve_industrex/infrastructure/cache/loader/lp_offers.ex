defmodule EveIndustrex.Infrastructure.Cache.Loader.LpOffers do
  alias EveIndustrex.LoyaltyPoints.LpOffer.Query

  def init(), do: :ets.insert(:lp_offers, Query.get_offers_for_cache())
end
