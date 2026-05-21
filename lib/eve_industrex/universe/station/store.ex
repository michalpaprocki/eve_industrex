defmodule EveIndustrex.Universe.Station.Store do

  def get_stations, do: :ets.tab2list(:system_locations)
end
