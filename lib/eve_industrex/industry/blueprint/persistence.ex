defmodule EveIndustrex.Industry.Blueprint.Persistence do
  alias EveIndustrex.Industry.Blueprint
  alias EveIndustrex.Repo

  def upsert_all(list_of_blueprints, return? \\ false) when is_list(list_of_blueprints) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_blueprints, fn r ->
     %{
        blueprint_type_id: r.blueprint_type_id,
        max_production_limit: r.max_production_limit,
        inserted_at: now,
        updated_at: now
      }
    end)
    Repo.insert_all(
      Blueprint,
      rows,
      on_conflict: {:replace, [:max_production_limit, :updated_at]},
      conflict_target: :blueprint_type_id,
      returning: return?
    )
  end

  def upsert(blueprint) do
    %Blueprint{}
    |> Blueprint.changeset(blueprint)
    |> Repo.insert(on_conflict: {:replace, [:max_production_limit, :updated_at]}, conflict_target: :blueprint_type_id)
  end
end
