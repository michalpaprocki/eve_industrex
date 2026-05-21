defmodule EveIndustrex.Universe.Station.Query do
  import Ecto.Query
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Station
  def get_trade_hub_station_ids(), do: [60003760,60008494,60011866,60004588,60005686]
  def get_stations_for_cache(), do: from(s in Station, select: {s.station_id, s.system_id, s.name, :station}) |> Repo.all()
end
