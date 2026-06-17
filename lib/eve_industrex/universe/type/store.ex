defmodule EveIndustrex.Universe.Type.Store do

  def get_type_id_details(type_id) when is_number(type_id) do
    case :ets.lookup(:types, type_id) do
      [{_id, map}] ->

        map
      _-> nil
    end
  end
  def get_type_id_details(type_id) when is_binary(type_id) do
    case :ets.lookup(:types, String.to_integer(type_id)) do
      [{_id, map}] ->

        map
      _-> nil
    end
  end
end
