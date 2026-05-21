defmodule EveIndustrex.Industry.BlueprintActivityProduct.Persistence do
  alias EveIndustrex.Industry.BlueprintActivityProduct
  alias EveIndustrex.Repo

  def upsert_all(list_of_blueprints, return? \\ false) when is_list(list_of_blueprints) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows =
      Enum.flat_map(list_of_blueprints, fn bp ->
        Enum.flat_map(bp.activities, fn activity ->
          Enum.map(activity[:products] || [], fn product ->
            %{
              blueprint_type_id: bp.blueprint_type_id,
              activity_type: activity.activity_type,
              type_id: product.type_id,
              quantity: product.quantity,
              probability: product.probability,
              inserted_at: now,
              updated_at: now
            }
          end)
        end)
      end)
    Repo.insert_all(
      BlueprintActivityProduct,
      rows,
      on_conflict: {:replace, [:quantity, :updated_at]},
      conflict_target: [:blueprint_type_id, :activity_type, :type_id],
      returning: return?
    )
  end
end
