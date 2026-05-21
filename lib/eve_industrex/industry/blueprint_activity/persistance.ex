defmodule EveIndustrex.Industry.BlueprintActivity.Persistance do
  alias EveIndustrex.Repo
  alias EveIndustrex.Industry.BlueprintActivity

  def upsert_all(list_of_blueprints, return? \\ false) when is_list(list_of_blueprints) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.flat_map(list_of_blueprints, fn bp ->
      Enum.map(bp.activities, fn activity ->
      %{
        blueprint_type_id: bp.blueprint_type_id,
        activity_type: activity.activity_type,
        time: activity.time,
        inserted_at: now,
        updated_at: now
      }
      end)
    end)
    Repo.insert_all(
      BlueprintActivity,
      rows,
      on_conflict: {:replace, [:time, :updated_at]},
      conflict_target: [:blueprint_type_id, :activity_type],
      returning: return?
    )
  end

  def upsert(blueprint_activity) do
    %BlueprintActivity{}
    |> BlueprintActivity.changeset(blueprint_activity)
    |> Repo.insert(on_conflict: {:replace, [:time, :updated_at]}, conflict_target: [:blueprint_type_id, :activity_type])
  end
end
