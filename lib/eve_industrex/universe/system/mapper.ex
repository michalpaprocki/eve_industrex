defmodule EveIndustrex.Universe.System.Mapper do


  def from_dump(data) do
    %{
      system_id: Map.get(data, "_key"),
      name: Map.get(Map.get(data, "name"), "en"),
      security_status: Map.get(data, "securityStatus"),
      constellation_id: Map.get(data, "constellationID")
    }
  end

  def from_esi(data) do
    %{
      system_id: Map.get(data, "system_id"),
      name: Map.get(data, "name"),
      security_status: Map.get(data, "security_status"),
      constellation_id: Map.get(data, "constellation_id")
    }
  end
end
