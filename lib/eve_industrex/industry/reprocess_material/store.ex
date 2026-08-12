defmodule EveIndustrex.Industry.ReprocessMaterial.Store do
  alias EveIndustrex.Universe.Type
  @moduledoc false
  def get_type_reprocess_material(type_id) when is_number(type_id) do
    case :ets.lookup(:reprocess_materials, type_id) do
      [] ->
        []

      materials ->
        Enum.map(materials, fn m ->
          %{
            name: Type.Store.get_type_id_details(elem(m, 1))[:name],
            material_type_id: elem(m, 1),
            quantity: elem(m, 2),
            min_quantity: elem(m, 3),
            max_quantity: elem(m, 4)
          }
        end)
    end
  end

  def get_type_reprocess_material(type_id) when is_binary(type_id) do
    case :ets.lookup(:reprocess_materials, String.to_integer(type_id)) do
      [] ->
        []

      materials ->
        Enum.map(materials, fn m ->
          %{
            name: Type.Store.get_type_id_details(elem(m, 1))[:name],
            material_type_id: elem(m, 1),
            quantity: elem(m, 2),
            min_quantity: elem(m, 3),
            max_quantity: elem(m, 4)
          }
        end)
    end
  end

  def get_type_by_reprocess_material(type_id) when is_binary(type_id) do
    case :ets.match(:reprocess_materials, {:"$1", String.to_integer(type_id), :_, :_, :_}) do
      [] ->
        []

      [results] ->
        Enum.map(results, fn r ->
          %{type_id: r, name: Type.Store.get_type_id_details(r)[:name]}
        end)
        |> Enum.sort_by(& &1.name, :asc)
    end
  end

  def get_type_by_reprocess_material(type_id) when is_integer(type_id) do
    case :ets.match(:reprocess_materials, {:"$1", type_id, :_, :_, :_}) do
      [] ->
        []

      results ->
        Enum.map(results, fn r ->
          %{type_id: hd(r), name: Type.Store.get_type_id_details(hd(r))[:name]}
        end)
        |> Enum.sort_by(& &1.name, :asc)
    end
  end
end
