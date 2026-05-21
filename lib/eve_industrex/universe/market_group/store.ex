defmodule EveIndustrex.Universe.MarketGroup.Store do

  def get_init_market_groups(), do: :ets.tab2list(:market_groups)
  def get_market_group_children(market_group_id), do: :ets.match(:market_group_children, {market_group_id, :"$1"}) |> List.flatten()
  def get_market_group_types(market_group_id), do: :ets.match(:market_types, {market_group_id, :"$1"}) |> List.flatten()
end
