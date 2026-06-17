defmodule EveIndustrex.Universe.MarketGroup.Store do

  def get_init_market_groups(), do: :ets.tab2list(:market_groups)  |> Enum.sort_by(&elem(&1, 1))
  def get_market_group_children(market_group_id), do: :ets.match(:market_group_children, {market_group_id, :"$1"}) |> List.flatten() |> Enum.sort_by(& &1.name)
  def get_market_group_types(market_group_id), do: :ets.match(:market_types, {market_group_id, :"$1"}) |> List.flatten()
  def get_all_market_group_types(), do: :ets.tab2list(:market_types)
  def get_types() do

    :ets.tab2list(:market_types)
  end
  def get_type(type_id) when is_number(type_id) do
    case :ets.lookup(:market_types_lookup, type_id) do
      [{type_id, name}] ->
        {type_id, name}
      [] ->
        nil
    end
  end
  def get_type(type_id) when is_binary(type_id) do
    case :ets.lookup(:market_types_lookup, String.to_integer(type_id)) do
      [{type_id, name}] ->
        {type_id, name}
      [] ->
        nil
    end
  end
end
