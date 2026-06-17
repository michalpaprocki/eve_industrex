defmodule EveIndustrex.Market.MarketOrder.Store do


  def get_count() do
    :ets.tab2list(get_market_orders_table_id()) |>  length()
  end
  def get_market_orders(type_id, type) when is_binary(type_id) do
    :ets.lookup(get_market_orders_table_id(), {String.to_integer(type_id), type}) |> Enum.map(fn x -> elem(x, 1) end)
  end
  def get_market_orders(type_id, type) when is_number(type_id) do
    :ets.lookup(get_market_orders_table_id(), {type_id, type}) |> Enum.map(fn x -> elem(x, 1) end)
  end
  def get_ask_bid_from_hub(location_id, type_id) do
    case :ets.lookup(get_ask_bid_table_id(), {location_id, type_id}) do
      [{{_location, _type_id}, {max_buy, min_sell}}] ->
        %{
          min_sell: min_sell,
          max_buy: max_buy
        }
        [] ->
          %{
          min_sell: nil,
          max_buy: nil
        }
    end
  end
  defp get_market_orders_table_id() do
    :persistent_term.get(:market_orders_tid)
  end
  defp get_ask_bid_table_id() do
    :persistent_term.get(:trade_hub_bid_ask_spread_tid)
  end
end
