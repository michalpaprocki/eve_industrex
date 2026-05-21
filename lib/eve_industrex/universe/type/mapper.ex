defmodule EveIndustrex.Universe.Type.Mapper do
  def from_dump(data) do
    %{
      type_id: Map.get(data, "_key"),
      name: Map.get(Map.get(data, "name"), "en"),
      capacity: Map.get(data, "capacity"),
      description: get_desc(data),
      icon_id: Map.get(data, "graphicID"),
      mass: Map.get(data, "mass"),
      packaged_volume: Map.get(data, "packagedVolume"),
      portion_size: Map.get(data, "portionSize"),
      published: Map.get(data, "published"),
      radius: Map.get(data, "radius"),
      volume: Map.get(data, "volume"),
      group_id: Map.get(data, "groupID"),
      market_group_id: Map.get(data, "marketGroupID"),
    }
  end

  def from_esi(data) do
    %{
      type_id: Map.get(data, "type_id"),
      name: Map.get(data, "name"),
      capacity: Map.get(data, "capacity"),
      description: Map.get(data, "description"),
      icon_id: Map.get(data, "graphic_id"),
      mass: Map.get(data, "mass"),
      packaged_volume: Map.get(data, "packaged_volume"),
      portion_size: Map.get(data, "portion_size"),
      published: Map.get(data, "published"),
      radius: Map.get(data, "radius"),
      volume: Map.get(data, "volume"),
      group_id: Map.get(data, "group_id"),
      market_group_id: Map.get(data, "market_group_id"),
    }
  end
  defp get_desc(map) do
    if Map.has_key?(map, "description"), do: Map.get(Map.get(map, "description"), "en"), else: nil
  end
end
