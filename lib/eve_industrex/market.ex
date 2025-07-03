defmodule EveIndustrex.Market do
  alias EveIndustrex.Schemas.{Station, System, MarketOrder,Constellation, Region}
  alias EveIndustrex.Universe
  alias EveIndustrex.ESI.Markets
  alias EveIndustrex.Repo
  import Ecto.Query

  def get_market_orders(type_id) do
        query = from(m in MarketOrder, join: station in Station, on: m.station_id == station.station_id, join: system in System, on: station.system_id == system.system_id, join: c in Constellation, on: system.constellation_id == c.constellation_id, join: r in Region, on: c.region_id == r.region_id, where: m.type_id == ^type_id, preload: [:station, station: :system, station: [system: :constellation], station: [system: [constellation: :region]]])
        Repo.all(query)
  end
  def get_market_orders(region, type_id) do
    case Universe.get_region(region) do
      nil -> {:error, "No such region exists"}
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
    from(m in MarketOrder, join: s in Station, on: m.station_id == s.station_id, join: system in System, on: s.system_id == system.system_id, where: m.type_id in ^type_ids and m.station_id == ^station_id, order_by: [asc: m.price], preload: [:station, station: :system]) |> Repo.all
  end
  # def get_market_buy_orders_by_type(type_ids, station_id) do
  #   from(m in MarketOrder, join: s in Station, on: m.station_id == s.station_id, join: system in System, on: s.system_id == system.system_id, where: m.type_id in ^type_ids and m.is_buy_order == true and m.station_id == ^station_id ,  order_by: [desc: m.price], preload: [:station, station: :system]) |> Repo.all
  # end

  def get_market_orders_for_appraisal(type_id, station_id) do
    from(m in MarketOrder, join: station in Station, on: m.station_id == station.station_id, where: m.type_id == ^type_id and m.station_id == ^station_id, preload: [:station]) |> Repo.all
  end
  def update_market_orders(region) do
    case Universe.get_region(region) do
      nil -> {:error, "No such region exists"}
      found_region ->
        delete_market_orders(region)
        orders = Markets.fetch_market_orders(found_region.region_id)
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, orders, fn order -> prep_and_save_orders(order) end)
        |> Stream.run()
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
  defp prep_and_save_orders(order) do
    if order.location_id < 600000000 do
    %MarketOrder{}
    |> MarketOrder.changeset(order)
    |> Ecto.Changeset.change(station_id: order.location_id)
    |> Repo.insert()
  else
    %MarketOrder{}
    |> MarketOrder.changeset(order)
    |> Repo.insert()
  end
end
end
