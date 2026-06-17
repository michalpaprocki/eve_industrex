defmodule EveIndustrex.Infrastructure.Cache.Loader.Blueprint do
  alias EveIndustrex.Industry.Blueprint

  def init() do
    blueprints = Blueprint.Query.get_blueprint_for_cache()
    |> Enum.map(fn b ->
      {b.blueprint_type_id, %{
        blueprint_type_id: b.blueprint_type_id,
        max_production_limit: b.max_production_limit,
        activities: Enum.map(b.activities, fn a ->
          %{
            activity: a.activity_type,
            time: a.time,
            materials: Enum.filter(a.materials, fn m ->
              m.activity_type == a.activity_type
            end) |> Enum.map(fn m ->
              %{
                quantity: m.quantity,
                type_id: m.type_id,
              }
            end),
            products: Enum.filter(a.products, fn p ->
              p.activity_type == a.activity_type
            end) |> Enum.map(fn p ->
              %{
                quantity: p.quantity,
                type_id: p.type_id,
                probability: p.probability
              }
            end)
          }
        end)
      }}
    end)
    :ets.insert(:blueprints, blueprints)
  end
end
