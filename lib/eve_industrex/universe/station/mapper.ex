defmodule EveIndustrex.Universe.Station.Mapper do

  def from_dump(data) do
    %{
      station_id: Map.get(data, "_key"),
      name: Map.get(Map.get(data, "name"), "en"),
      reprocessing_efficiency: Map.get(data, "reprocessingEfficiency"),
      reprocessing_stations_take: Map.get(data, "reprocessingStationsTake"),
      services: Map.get(data, "services"),
      system_id: Map.get(data, "systemID")
    }
  end

  def from_esi(data) do
    %{
      station_id: Map.get(data, "station_id"),
      name: Map.get(data, "name"),
      reprocessing_efficiency: Map.get(data, "reprocessing_efficiency"),
      reprocessing_stations_take: Map.get(data, "reprocessing_stations_take"),
      services: Map.get(data, "services"),
      system_id: Map.get(data, "system_id")
    }
  end
  def dump_to_ids(map), do: Enum.map(map, fn m ->  Map.get(m, "_key") end)
end
