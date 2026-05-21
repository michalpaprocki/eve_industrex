defmodule EveIndustrex.Industry.BlueprintActivityMaterial.Persistence do
  alias EveIndustrex.Industry.BlueprintActivityMaterial
  alias EveIndustrex.Repo

  def upsert_all(list_of_blueprints, return? \\ false) when is_list(list_of_blueprints) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows =
      Enum.flat_map(list_of_blueprints, fn bp ->
        Enum.flat_map(bp.activities, fn activity ->
          Enum.map(activity[:materials] || [], fn material ->
            %{
              blueprint_type_id: bp.blueprint_type_id,
              activity_type: activity.activity_type,
              type_id: material.type_id,
              quantity: material.quantity,
              inserted_at: now,
              updated_at: now
            }
          end)
        end)
      end)
    Repo.insert_all(
      BlueprintActivityMaterial,
      rows,
      on_conflict: {:replace, [:quantity, :updated_at]},
      conflict_target: [:blueprint_type_id, :activity_type, :type_id],
      returning: return?
    )
  end
end
