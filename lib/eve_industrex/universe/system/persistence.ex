defmodule EveIndustrex.Universe.System.Persistence do

  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.System

  def upsert_all(list_of_systems, return? \\ false) when is_list(list_of_systems) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_systems, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      System,
      rows,
      on_conflict: {:replace, [:name, :updated_at, :constellation_id, :security_status]},
      conflict_target: :system_id,
      returning: return?
    )
  end

  def upsert(constellation) do
    %System{}
    |> System.changeset(constellation)
    |> Repo.insert(on_conflict: {:replace, [:name, :updated_at, :constellation_id, :security_status]}, conflict_target: :system_id)
  end
end
