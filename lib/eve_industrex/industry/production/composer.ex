defmodule EveIndustrex.Industry.Production.Composer do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Industry

  @moduledoc """
  Assembles a blueprint map for Industry related liveviews.
  """

  def reactions_view() do
    formulas = Industry.Blueprint.Store.get_reaction_formulas()

    Enum.map(formulas, fn f ->
      compose_from_bp(f)
    end)
  end

  def compose_from_bp({id, f}) do
    {id, Industry.Blueprint.Store.get_blueprint(id) |> handle_prepare(f)}
  end

  defp handle_prepare({_id, bp}, type) do
    Map.merge(type, prepare_blueprint(bp))
  end

  defp prepare_blueprint(bp) do
    %{
      blueprint_type_id: bp.blueprint_type_id,
      max_production_limit: bp.max_production_limit,
      activities:
        Map.new(bp.activities, fn a ->
          {a.activity,
           %{
             time: a.time,
             materials:
               Enum.map(a.materials, fn m ->
                 %{
                   type_id: m.type_id,
                   quantity: m.quantity,
                   name: Type.Store.get_type_id_details(m.type_id).name,
                   category_id: Type.Store.get_type_id_details(m.type_id).category_id
                 }
               end)
               |> Enum.sort_by(& &1.name, :asc),
             products:
               Enum.map(a.products, fn p ->
                 %{
                   type_id: p.type_id,
                   quantity: p.quantity,
                   name: Type.Store.get_type_id_details(p.type_id).name,
                   probability: p.probability,
                   category_id: Type.Store.get_type_id_details(p.type_id).category_id
                 }
               end)
               |> Enum.sort_by(& &1.name, :asc)
           }}
        end)
    }
  end
end
