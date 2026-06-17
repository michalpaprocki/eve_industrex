defmodule EveIndustrex.Infrastructure.Cache.Loader.MarketGroup do
alias EveIndustrex.Universe.MarketGroup.Query
  def init do
    :ets.insert(:market_groups, Query.get_market_groups_for_cache())
    :ets.insert(:market_group_children, Query.get_market_groups_children_for_cache())
    :ets.insert(:market_types, Query.get_market_groups_types())
    :ets.insert(:market_types_lookup, Query.get_market_groups_types_lookup())
  end
end
