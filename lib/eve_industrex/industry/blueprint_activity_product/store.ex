defmodule EveIndustrex.Industry.BlueprintActivityProduct.Store do
  alias EveIndustrex.Universe.Type

  def get_bps_by_product(product_type_id) when is_binary(product_type_id) do
    :ets.tab2list(:blueprints)
    |> Enum.filter(fn {_k, bp} ->
      Enum.filter(bp.activities, fn a ->
        Enum.any?(a.products, fn p ->
          p.type_id == String.to_integer(product_type_id)
        end)
      end) != []
    end)
    |> Enum.map(fn {id, bp} ->
      %{type_id: bp.blueprint_type_id, name: Type.Store.get_type_id_details(id)[:name]}
    end)
  end

  def get_bps_by_product(product_type_id) when is_integer(product_type_id) do
    :ets.tab2list(:blueprints)
    |> Enum.filter(fn {_k, bp} ->
      Enum.filter(bp.activities, fn a ->
        Enum.any?(a.products, fn p ->
          p.type_id == product_type_id
        end)
      end) != []
    end)
    |> Enum.map(fn {id, bp} ->
      %{type_id: bp.blueprint_type_id, name: Type.Store.get_type_id_details(id)[:name]}
    end)
  end

  def get_product_by_bp(type_id) when is_binary(type_id) do
    case :ets.lookup(:blueprints, String.to_integer(type_id)) do
      [] ->
        []

      [{_type_id, bp}] ->
        Enum.map(bp.activities, fn a -> a.products end)
        |> List.flatten()
        |> Enum.map(fn p ->
          Map.put(p, :name, Type.Store.get_type_id_details(p.type_id)[:name])
        end)
    end
  end

  def get_product_by_bp(type_id) when is_integer(type_id) do
    case :ets.lookup(:blueprints, type_id) do
      [] ->
        []

      [{_type_id, bp}] ->
        Enum.map(bp.activities, fn a -> a.products end)
        |> List.flatten()
        |> Enum.map(fn p ->
          Map.put(p, :name, Type.Store.get_type_id_details(p.type_id)[:name])
        end)
    end
  end
end
