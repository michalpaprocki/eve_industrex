defmodule EveIndustrex.Market.MarketOrder.Service do
  alias EveIndustrex.Universe.Station
  alias EveIndustrex.Market.MarketOrder
  alias EveIndustrex.Repo
  import Ecto.Query
  @trade_hub_station_ids Station.Query.get_trade_hub_station_ids()
  require Logger
  def project_orders_to_cache(tid) do

    max_gen = from(mo in MarketOrder, select: max(mo.generation))

    query = from(mo in MarketOrder, where:  mo.generation == subquery(max_gen), select: %{
        type_id: mo.type_id,
        is_buy_order: mo.is_buy_order,
        order_id: mo.order_id,
        price: mo.price,
        volume_remain: mo.volume_remain,
        volume_total: mo.volume_total,
        location_id: mo.location_id,
        range: mo.range,
        region_id: mo.region_id,
        min_volume: mo.min_volume,
        issued: mo.issued,
        duration: mo.duration
        })
        {ms, _result} = :timer.tc(fn ->

          Repo.transaction(fn ->

            Repo.stream(query)

            |> Stream.map(&to_ets_row/1)
            |> Stream.chunk_every(5000)
            |> Stream.each(&:ets.insert(tid, &1))
            |> Stream.run()
          end, timeout: :infinity)
        end)
        Logger.info("Projection took #{ms / 1_000_000}s pid=#{inspect(self())} ")
      old_tid = :persistent_term.get(:market_orders_tid)

    :persistent_term.put(:market_orders_tid, tid)

    :ets.delete(old_tid)


  end
  def project_bid_ask_for_trade_hub(tid) do

    max_gen = from(mo in MarketOrder, select: max(mo.generation))

    query = from(mo in MarketOrder, where: mo.generation == subquery(max_gen) and mo.location_id in ^@trade_hub_station_ids,
              group_by: [mo.location_id, mo.type_id],
              select: %{
                location_id: mo.location_id,
                type_id: mo.type_id,
                max_buy:
                  filter(max(mo.price), mo.is_buy_order == true),
                min_sell:
                  filter(min(mo.price), mo.is_buy_order == false)
              }
            )

        {ms, _result} = :timer.tc(fn ->

          Repo.transaction(fn ->

            Repo.stream(query)

            |> Stream.map(&to_ets_bid_ask_row/1)
            |> Stream.chunk_every(5000)
            |> Stream.each(&:ets.insert(tid, &1))
            |> Stream.run()
          end, timeout: :infinity)
        end)
        Logger.info("Bid - Ask Projection took #{ms / 1_000_000}s pid=#{inspect(self())} ")
      old_tid = :persistent_term.get(:trade_hub_bid_ask_spread_tid)

    :persistent_term.put(:trade_hub_bid_ask_spread_tid, tid)

    :ets.delete(old_tid)

  end

  defp to_ets_row(order) do
    {
      {order.type_id, get_order_type(order.is_buy_order)}, project_order(order)
    }
  end
  defp to_ets_bid_ask_row(order) do

    {
      {order.location_id, order.type_id}, {order.max_buy, order.min_sell}
    }
  end
  defp get_order_type(market_order_type), do: (if market_order_type == true, do: :buy, else: :sell)
  defp project_order(order) do
    {order.order_id, order.price, order.volume_remain, order.volume_total, order.min_volume, order.location_id, order.range, order.region_id, order.duration, order.issued, get_security_status(order.location_id)}
  end
  defp get_security_status(location_id) do
    case EveIndustrex.Universe.Station.Store.get_station(location_id) do
      {_, _, _, _, sec_status, _, _, _, _} ->
        sec_status
      nil ->
        # it's a structure
        1.0
    end
  end
end
