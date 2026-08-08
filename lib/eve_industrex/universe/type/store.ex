defmodule EveIndustrex.Universe.Type.Store do
  @moduledoc false
  def get_type_id_details(type_id) when is_number(type_id) do
    case :ets.lookup(:types, type_id) do
      [{_id, map}] ->
        map

      _ ->
        nil
    end
  end

  def get_type_id_details(type_id) when is_binary(type_id) do
    case :ets.lookup(:types, String.to_integer(type_id)) do
      [{_id, map}] ->
        map

      _ ->
        nil
    end
  end

  def get_all() do
    :ets.tab2list(:types)
  end

  def exists?(type_id) do
    :ets.member(:types, type_id)
  end

  def add(type) when is_tuple(type) do
    :ets.insert(:types, type)
  end

  def filter_unknown(ids) do
    Enum.filter(ids, fn id ->
      !exists?(id)
    end)
  end

  def search(query) do
    case get_all() do
      [] ->
        []

      types ->
        Enum.filter(types, fn {_k, type} ->
          String.contains?(type.search_name, String.downcase(query)) and type.published == true
        end)
        |> Enum.sort_by(&elem(&1, 1).name, :asc)
    end
  end
end
