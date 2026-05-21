defmodule EveIndustrex.Universe.MarketGroup.Mapper do
  def from_dump(data) do
    %{
      market_group_id: Map.get(data, "_key"),
      name: Map.get(Map.get(data, "name"), "en"),
      description: get_desc(data),
      parent_group_id: Map.get(data, "parentGroupID", nil)
    }
  end
  def from_esi(data) do
    %{
      market_group_id: Map.get(data, "market_group_id"),
      name: Map.get(data, "name"),
      description: Map.get(data, "description"),
      parent_group_id: Map.get(data, "parent_group_id", nil)
    }
  end
    defp get_desc(map) do
    if Map.has_key?(map, "description"), do: Map.get(Map.get(map, "description"), "en"), else: nil
  end
end
