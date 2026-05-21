defmodule EveIndustrex.LoyaltyPoints.NpcCorp.Mapper do

  def from_dump(data) do
    %{
    :name => Map.get(Map.get(data, "name"), "en"),
    :corp_id => Map.get(data,"_key"),
    :description => get_desc(data)
    }
  end
  def from_esi(data) do
    %{
    :name => Map.get(data, "name"),
    :corp_id => Map.get(data,"corp_id"),
    :description => Map.get(data, "description")
    }
  end
  defp get_desc(%{"description" => desc} = _map), do: Map.get(desc, "en")
  defp get_desc(_map), do: nil

end
