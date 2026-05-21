defmodule EveIndustrex.Industry.BlueprintActivityProduct.Mapper do


  def from_dump(data) do
      %{
        quantity: Map.get(data, "quantity"),
        type_id: Map.get(data, "typeID"),
        probability: Map.get(data, "probability", nil)
      }
  end
end
