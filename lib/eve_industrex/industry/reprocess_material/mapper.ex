defmodule EveIndustrex.Industry.ReprocessMaterial.Mapper do

  def from_dump(%{"materials" => mats} = data) do
    %{
      source_type_id: Map.get(data, "_key"),
      materials: Enum.map(mats, fn m ->
        %{
          material_type_id: Map.get(m, "materialTypeID"),
          quantity: Map.get(m, "quantity")
        }
      end)
    }
  end
  def from_dump(%{"randomizedMaterials" => r_mats} = data) do
    %{
      source_type_id: Map.get(data, "_key"),
      randomized_materials: Enum.map(r_mats, fn m ->
        %{
          material_type_id: Map.get(m, "materialTypeID"),
          quantity_max: Map.get(m, "quantityMax"),
          quantity_min: Map.get(m, "quantityMin")
        }
      end)
    }
  end
end
