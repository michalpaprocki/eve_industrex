defmodule EveIndustrex.Universe.MarketGroup.Store do
  @moduledoc false
  def get_init_market_groups(), do: :ets.tab2list(:market_groups) |> Enum.sort_by(&elem(&1, 1))

  def get_market_group(market_group_id) do
    case :ets.lookup(:market_groups, market_group_id) do
      [] ->
        []

      [{^market_group_id, name}] ->
        {market_group_id, name}
    end
  end

  def get_market_group_children(market_group_id),
    do:
      :ets.match(:market_group_children, {market_group_id, :"$1"})
      |> List.flatten()
      |> Enum.sort_by(& &1.name)

  def get_market_group_types(market_group_id),
    do: :ets.match(:market_types, {market_group_id, :"$1"}) |> List.flatten()

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

  def exists?(market_group_id) do
    :ets.member(:market_groups, market_group_id) or
      :ets.member(:market_group_children, market_group_id)
  end

  def filter_unknown(ids) do
    Enum.filter(ids, fn id ->
      !exists?(id)
    end)
  end

  def add_parent(mg) do
    :ets.insert(:market_groups, mg)
  end

  def add_children(mg) do
    :ets.insert(:market_group_children, mg)
  end
end
