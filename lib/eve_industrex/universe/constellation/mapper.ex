defmodule EveIndustrex.Universe.Constellation.Mapper do

  def from_dump(data) do
    %{
      constellation_id: Map.get(data, "_key"),
      name: Map.get(Map.get(data, "name"), "en"),
      region_id: Map.get(data, "regionID")
    }
  end

  def from_esi(data) do
    %{
      constellation_id: Map.get(data, "constellation_id"),
      name: Map.get(data, "name"),
      region_id: Map.get(data, "region_id")
    }
  end
end
