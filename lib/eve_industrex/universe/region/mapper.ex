defmodule EveIndustrex.Universe.Region.Mapper do

  def from_dump(data) do
    %{
      region_id: Map.get(data, "_key"),
      name: Map.get(Map.get(data, "name"), "en"),
      description: get_desc(data)
    }
  end
  def from_esi(data) do
      %{
      data_id: Map.get(data, "region_id"),
      name: Map.get(data, "name"),
      description: Map.get(data, "description")
    }
  end
  defp get_desc(map) do
    if Map.has_key?(map, "description"), do: Map.get(Map.get(map, "description"), "en"), else: nil
  end
end
