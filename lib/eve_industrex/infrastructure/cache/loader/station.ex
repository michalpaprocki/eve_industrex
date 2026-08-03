defmodule EveIndustrex.Infrastructure.Cache.Loader.Station do
  alias EveIndustrex.Universe.Station.Query
  @moduledoc false
  def init, do: :ets.insert(:stations, Query.get_stations_with_locations())
end
