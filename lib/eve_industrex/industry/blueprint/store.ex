defmodule EveIndustrex.Industry.Blueprint.Store do
  alias EveIndustrex.Universe.Type
  @moduledoc false
  def get_blueprint(id) do
    case :ets.lookup(:blueprints, id) do
      [{id, bp}] ->
        {id, bp}

      [] ->
        []
    end
  end

  def get_all() do
    :ets.tab2list(:blueprints)
  end

  def get_bp_materials(type_id) do
    case get_blueprint(type_id) do
      [] ->
        []

      {_id, bp} ->
        Enum.map(bp.activities, fn a ->
          %{activity: a.activity, materials: a.materials}
        end)
        |> List.flatten()
        |> Enum.map(fn m ->
          %{
            m
            | materials:
                Enum.map(m.materials, fn mat ->
                  Map.put(mat, :name, Type.Store.get_type_id_details(mat.type_id)[:name])
                end)
          }
        end)
    end
  end
end
