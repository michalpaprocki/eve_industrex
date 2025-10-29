defmodule EveIndustrex.Market do
  alias EveIndustrex.Logger.EiLogger
  alias EveIndustrex.Schemas.Type
  alias EveIndustrex.Schemas.AveragePrice
  alias EveIndustrex.Schemas.{Station, System, MarketOrder,Constellation, Region, MarketStatistic}
  alias EveIndustrex.Universe
  alias EveIndustrex.ESI.Markets
  alias EveIndustrex.Repo
  alias EveIndustrex.Utils
  import Ecto.Query

  def get_market_orders(type_id) do
        query = from(m in MarketOrder, where: fragment("? +(? * interval '1 day') > now()", m.issued, m.duration), join: station in Station, on: m.station_id == station.station_id, join: system in System, on: station.system_id == system.system_id, join: c in Constellation, on: system.constellation_id == c.constellation_id, join: r in Region, on: c.region_id == r.region_id, where: m.type_id == ^type_id, preload: [:station, station: :system, station: [system: :constellation], station: [system: [constellation: :region]]])
        Repo.all(query)
  end
  def get_market_orders(region, type_id) do
    case Universe.get_region(region) do
      nil ->
         fun = Function.info(&get_market_orders/2)
        {:error,{:enoent, "Missing entity required: region: #{region}", "#{Keyword.get(fun, :module)}"<>".#{Keyword.get(fun, :name)}"<>"/#{Keyword.get(fun, :arity)}"}}
      found_region ->
        query = from(m in MarketOrder, join: station in Station, on: m.station_id == station.station_id, join: system in System, on: station.system_id == system.system_id, join: c in Constellation, on: system.constellation_id == c.constellation_id, join: r in Region, on: c.region_id == r.region_id, where: r.region_id == ^found_region.region_id and m.type_id == ^type_id, preload: [:station, station: :system, station: [system: :constellation], station: [system: [constellation: :region]]])
        Repo.all(query)
    end
  end

  def get_order_by_order_id(order_id), do: from(m in MarketOrder, where: m.order_id == ^order_id) |> Repo.all()
  def get_market_orders_by_type(type_id) do
    from(m in MarketOrder, where: m.type_id == ^type_id) |> Repo.all
  end
  def get_market_orders_by_type_and_station(type_ids, station_id) do
    from(m in MarketOrder, join: s in Station, on: m.station_id == s.station_id, join: system in System, on: s.system_id == system.system_id,
    where: m.type_id in ^type_ids and m.station_id == ^station_id,
    order_by: [asc: m.price], preload: [:station, station: :system]) |> Repo.all
  end
  def dev_get_market_orders_by_type_and_station(type_ids, station_id) do
    from(m in MarketOrder, join: s in Station, on: m.station_id == s.station_id, join: system in System, on: s.system_id == system.system_id,
    where: m.type_id in ^type_ids and m.station_id == ^station_id and m.is_buy_order == false, distinct: [m.type_id],
    order_by: [asc: m.price], preload: [:station, station: :system]) |> Repo.all
  end
  def get_market_orders_for_type_and_station(type_id, station_id) do
    from(m in MarketOrder, join: s in Station, on: m.station_id == s.station_id, join: system in System, on: s.system_id == system.system_id,
    where: m.type_id == ^type_id and m.station_id == ^station_id,
    order_by: [asc: m.price], preload: [:station, station: :system]) |> Repo.all
  end
  def get_market_orders_for_appraisal(type_id, station_id) do
    from(m in MarketOrder, join: station in Station, on: m.station_id == station.station_id, where: m.type_id == ^type_id and m.station_id == ^station_id, preload: [:station]) |> Repo.all
  end
  def get_market_statistics(region_id, type_id) do
    from(ms in MarketStatistic, join: t in Type, on: ms.type_id == t.type_id, join: r in Region, on: r.region_id == ms.region_id, where: r.region_id == ^region_id and t.type_id == ^type_id, select: ms.date) |> Repo.all
  end
  def get_market_statistics_all() do
    from(ms in MarketStatistic) |> Repo.all
  end
  def get_latest_market_statistic(region_id, type_id) do
    from(ms in MarketStatistic, join: t in Type, on: ms.type_id == t.type_id, join: r in Region, on: r.region_id == ms.region_id, where: r.region_id == ^region_id and t.type_id == ^type_id, order_by: [desc: ms.date], limit: 1) |> Repo.one
  end
  def update_market_statistics(region_id, list_of_type_ids) do

     case Universe.get_region(region_id) do
      nil ->
        fun = Function.info(&update_market_orders/1)
        {:error,{:enoent, "Missing entity required: region: #{region_id}", "#{Keyword.get(fun, :module)}"<>".#{Keyword.get(fun, :name)}"<>"/#{Keyword.get(fun, :arity)}"}}
      found_region ->
          case Markets.fetch_market_statistics(found_region.region_id, list_of_type_ids) do
            {:error, error} ->
              {:error, error}
            {:ok, statistics} ->
              Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, statistics, fn {type, region_statistics} ->
                  if region_statistics == {"error", "Type not found!"} do
                    EiLogger.log(:error, {:bad_type_id, "#{Integer.to_string(type)} - Type not found!", "update_market_statistics/2"})
                    nil
                  else
                    Enum.map(region_statistics, fn region_statistic ->

                      %{
                        :type_id => type,
                        :region_id => found_region.region_id,
                        :average => region_statistic["average"],
                        :date => Date.from_iso8601!(region_statistic["date"]),
                        :highest => region_statistic["highest"],
                        :lowest => region_statistic["lowest"],
                        :order_count => region_statistic["order_count"],
                        :volume => region_statistic["volume"]
                      }
                    end)
                  end
              end) |> Enum.map(fn x -> if elem(x, 0) == :ok, do: elem(x, 1), else: nil end) |> Enum.filter(fn x -> x != nil end) |> Task.async_stream(fn data -> Repo.insert_all(MarketStatistic, data, on_conflict: :nothing) end, max_concurrency: 5, timeout: 20000)
          end

        :ok
      end
  end

  def delete_market_statistics_all() do
    Repo.delete_all(from(ms in MarketStatistic))
  end
  def update_market_orders(region) do
    case Universe.get_region(region) do
      nil ->
        fun = Function.info(&update_market_orders/1)
        {:error,{:enoent, "Missing entity required: region: #{region}", "#{Keyword.get(fun, :module)}"<>".#{Keyword.get(fun, :name)}"<>"/#{Keyword.get(fun, :arity)}"}}
      found_region ->
        delete_market_orders(region)
        case Markets.fetch_market_orders(found_region.region_id) do
          {:error, error} ->
            {:error, error}
          {:ok, orders} ->
            Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, orders, fn order -> prep_and_save_orders(order) end)
            |> Stream.run()
        end
    end
  end
  def get_all_market_orders(), do: Repo.all(MarketOrder)
  def delete_market_orders(region) do
    case Universe.get_region(region) do
      nil ->
        nil
      found_region ->
        query_stations = from(m in MarketOrder, join: station in Station, on: m.station_id == station.station_id, join: system in System, on: station.system_id == system.system_id, join: c in Constellation, on: system.constellation_id == c.constellation_id, join: r in Region, on: c.region_id == r.region_id, where: r.region_id == ^found_region.region_id)
        query_structures = from(m in MarketOrder, where: is_nil(m.station_id))
        Repo.delete_all(query_stations)
        Repo.delete_all(query_structures)
    end
  end

  def delete_all_market_orders() do
    Repo.delete_all(MarketOrder)
  end
  # to do: figure out how often average prices are updated
  def update_market_average_prices() do
    case Markets.fetch_market_average_prices() do
      {:error, error} ->
        {:error, error}
      {:ok, average_prices} ->
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, average_prices, fn ap ->
        %AveragePrice{} |> AveragePrice.changeset(ap) |> Ecto.Changeset.change(type_id: ap["type_id"]) |> Repo.insert()
        end) |> Stream.run()
    end
  end
  def get_type_average_prices(type_id) do
    subquery = from(av in AveragePrice, order_by: [desc: :inserted_at])
    from(t in Type, where: t.type_id == ^type_id) |> Repo.all |> Repo.preload(average_prices: subquery)
  end
   def get_type_current_average_prices(type_id) do
    subquery = from(av in AveragePrice, order_by: [desc: :inserted_at], limit: 1)
    from(t in Type, where: t.type_id == ^type_id) |> Repo.all |> Repo.preload(average_prices: subquery)
  end
  defp prep_and_save_orders(order) do
    if order["location_id"] < 600000000 do
    %MarketOrder{}
    |> MarketOrder.changeset(order)
    |> Ecto.Changeset.change(station_id: order["location_id"])
    |> Repo.insert()
  else
    %MarketOrder{}
    |> MarketOrder.changeset(order)
    |> Repo.insert()
    end
  end
end
