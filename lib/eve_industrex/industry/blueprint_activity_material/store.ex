defmodule EveIndustrex.Industry.BlueprintActivityMaterial.Store do
  alias EveIndustrex.Universe.Type

  def get_bps_by_material(material_type_id) when is_binary(material_type_id) do
    :ets.tab2list(:blueprints)
    |> Enum.filter(fn {_k, bp} ->
      Enum.filter(bp.activities, fn a ->
        Enum.any?(a.materials, fn m -> m.type_id == String.to_integer(material_type_id) end)
      end) !=
        []
    end)
  end

  def get_bps_by_material(material_type_id) when is_integer(material_type_id) do
    :ets.tab2list(:blueprints)
    |> Enum.filter(fn {_k, bp} ->
      Enum.filter(bp.activities, fn a ->
        Enum.any?(a.materials, fn m -> m.type_id == material_type_id end)
      end) != []
    end)
    |> Enum.map(fn {k, _v} ->
      %{type_id: k, name: Type.Store.get_type_id_details(k)[:name]}
    end)
  end
end
