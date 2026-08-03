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
end
