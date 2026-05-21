defmodule EveIndustrex.Industry.Blueprint.Mapper do

  def from_dump(data) do
    %{
      blueprint_type_id: Map.get(data, "_key"),
      max_production_limit: Map.get(data, "maxProductionLimit", nil),
      activities: Enum.map(data["activities"], fn a -> EveIndustrex.Industry.BlueprintActivity.Mapper.from_dump(a) end)
    }
  end
end
