defmodule EveIndustrex.Infrastructure.Cache.Loader.Station do
  alias EveIndustrex.Universe.Station.Query
  def init, do: :ets.insert(:system_locations, Query.get_stations_for_cache)
end
