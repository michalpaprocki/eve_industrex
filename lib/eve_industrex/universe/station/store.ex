defmodule EveIndustrex.Universe.Station.Store do


  def get_stations(), do: :ets.tab2list(:stations)
  def get_station(station_id) do
    case :ets.lookup(:stations, station_id) do
      [{station_id, station_name, sys_id, sys_name, security_status, con_id, con_name, reg_id, reg_name}] ->
        {station_id, station_name, sys_id, sys_name, security_status, con_id, con_name, reg_id, reg_name}
      [] ->
        nil
    end
  end
end
