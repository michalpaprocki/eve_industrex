defmodule EveIndustrex.Market.Service do
  alias EveIndustrex.Market.MarketOrder
  alias EveIndustrex.Universe
  def get_market_view(type_id) do
    buy_orders =
      MarketOrder.Store.get_market_orders(type_id, :buy)

    sell_orders =
      MarketOrder.Store.get_market_orders(type_id, :sell)


    buy_orders = Enum.map(buy_orders, fn x ->
        %{
          price: elem(x,1),
          volume_remain: elem(x,2),
          volume_total: elem(x,3),
          min_volume: elem(x, 4),
          range: elem(x, 6),
          duration: elem(x, 8),
          issued: elem(x, 9),
          location: build_location(elem(x, 5))
        }
    end)


    sell_orders = Enum.map(sell_orders, fn x ->
        %{
          price: elem(x,1),
          volume_remain: elem(x,2),
          volume_total: elem(x,3),
          min_volume: elem(x, 4),
          range: elem(x, 6),
          duration: elem(x, 8),
          issued: elem(x, 9),
          location:  build_location(elem(x, 5))
        }
    end)

    %{:buy_orders => buy_orders, :sell_orders => sell_orders}

  end

  def get_initial_prices_for_lp_view(location_id, type_ids) do
    Map.new(type_ids, fn type_id ->
      {type_id, MarketOrder.Store.get_ask_bid_from_hub(location_id, type_id)}
    end)
  end
  def get_mini_market_view(location_id, type_id) do
    buy_orders =
      MarketOrder.Store.get_market_orders(type_id, :buy)
      |>Enum.filter(fn o -> elem(o,5) == location_id end)

    sell_orders =
      MarketOrder.Store.get_market_orders(type_id, :sell)
      |>Enum.filter(fn o -> elem(o,5) == location_id end)

      buy_orders = Enum.map(buy_orders, fn x ->
        %{
          price: elem(x,1),
          volume_remain: elem(x,2),
          volume_total: elem(x,3),
          min_volume: elem(x, 4),
          range: elem(x, 6),
          duration: elem(x, 8),
          issued: elem(x, 9),
          location: build_location(elem(x, 5)),
          order_id: elem(x, 0)
        }
    end)


    sell_orders = Enum.map(sell_orders, fn x ->
        %{
          price: elem(x,1),
          volume_remain: elem(x,2),
          volume_total: elem(x,3),
          min_volume: elem(x, 4),
          range: elem(x, 6),
          duration: elem(x, 8),
          issued: elem(x, 9),
          location:  build_location(elem(x, 5)),
          order_id: elem(x, 0)
        }
    end)

    %{:buy_orders => buy_orders, :sell_orders => sell_orders}
  end
  defp build_location(location_id) do

    case Universe.Station.Store.get_station(location_id) do
      {station_id, station_name, _sys_id, sys_name, security_status, _con_id, con_name, _reg_id, reg_name} ->

       %{
          station_id: station_id ,name: station_name, system: sys_name, constellation: con_name, region: reg_name, security_status: security_status
        }
      nil ->

        nil
    end
  end
end
