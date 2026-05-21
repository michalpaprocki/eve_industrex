defmodule EveIndustrex.Industry.BlueprintActivitySkill.Mapper do


  def from_dump(data) do
    %{
      level: Map.get(data, "level"),
      type_id: Map.get(data, "typeID")
    }
  end
end
