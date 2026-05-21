defmodule EveIndustrex.Industry.BlueprintActivitySkill.Persistence do

alias EveIndustrex.Industry.BlueprintActivitySkill
alias EveIndustrex.Repo

def upsert_all(list_of_blueprints, return? \\ false) when is_list(list_of_blueprints) do
  now = DateTime.utc_now() |> DateTime.truncate(:second)
  rows =
    Enum.flat_map(list_of_blueprints, fn bp ->
      Enum.flat_map(bp.activities, fn activity ->
        Enum.map(activity[:skills] || [], fn skill ->
          %{
            blueprint_type_id: bp.blueprint_type_id,
            activity_type: activity.activity_type,
            type_id: skill.type_id,
            level: skill.level,
            inserted_at: now,
            updated_at: now
          }
        end)
      end)
      |> Enum.uniq_by(fn row ->
        {
          row.blueprint_type_id, row.activity_type, row.type_id
        }
      end)
    end)
  Repo.insert_all(
    BlueprintActivitySkill,
    rows,
    on_conflict: {:replace, [:level, :updated_at]},
    conflict_target: [:blueprint_type_id, :activity_type, :type_id],
    returning: return?
  )
end


end
