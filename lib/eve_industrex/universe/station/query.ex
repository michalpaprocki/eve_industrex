defmodule EveIndustrex.Universe.Station.Query do
  import Ecto.Query
  alias EveIndustrex.Universe.Region
  alias EveIndustrex.Universe.Constellation
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Station


  def get_trade_hub_station_ids(), do: [60003760,60008494,60011866,60004588,60005686]
  def get_trade_hubs() do
    Enum.map(get_trade_hub_station_ids(), fn id ->
      hub = Station.Store.get_station(id)
      %{
        name: elem(hub, 1),
        station_id: elem(hub, 0)
      }
    end)
  end
  def get_stations_for_cache(), do: from(s in Station, select: {s.station_id, s.name}) |> Repo.all()
  def get_stations(), do: Repo.all(Station)
  def get_stations_with_locations() do
    from(s in Station, join: sys in System, on: s.system_id == sys.system_id,
    join: c in Constellation, on: sys.constellation_id == c.constellation_id,
    join: r in Region, on: c.region_id == r.region_id,
    select: {
      s.station_id,
      s.name,

      sys.system_id,
      sys.name,
      sys.security_status,

      c.constellation_id,
      c.name,

      r.region_id,
      r.name
    }) |> Repo.all
  end
end
