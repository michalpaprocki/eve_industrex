defmodule EveIndustrex.Industry.SystemCostIndex.Mapper do
  @moduledoc false
  def from_esi(data) do
    Enum.map(Map.get(data, "cost_indices", []), fn ci ->
      create_activity_map(ci, Map.get(data, "solar_system_id", nil))
    end)
  end

  defp create_activity_map(data, system_id) do
    %{
      activity: put_activity(Map.get(data, "activity", nil)),
      system_id: system_id,
      cost_index: Map.get(data, "cost_index", nil)
    }
  end

  defp put_activity(nil), do: nil
  defp put_activity("manufacturing"), do: :manufacturing
  defp put_activity("copying"), do: :copying
  defp put_activity("invention"), do: :invention
  defp put_activity("reaction"), do: :reaction
  defp put_activity("researching_time_efficiency"), do: :researching_time_efficiency
  defp put_activity("researching_material_efficiency"), do: :researching_material_efficiency
end
