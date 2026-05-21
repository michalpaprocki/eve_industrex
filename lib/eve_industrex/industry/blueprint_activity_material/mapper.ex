defmodule EveIndustrex.Industry.BlueprintActivityMaterial.Mapper do

  def from_dump(data) do
      %{
        quantity: Map.get(data, "quantity"),
        type_id: Map.get(data, "typeID")
      }
  end
end
