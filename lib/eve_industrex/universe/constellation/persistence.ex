defmodule EveIndustrex.Universe.Constellation.Persistence do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Constellation

  def upsert_all(list_of_constellations, return? \\ false) when is_list(list_of_constellations) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_constellations, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      Constellation,
      rows,
      on_conflict: {:replace, [:name, :updated_at, :region_id]},
      conflict_target: :constellation_id,
      returning: return?
    )
  end

  def upsert(constellation) do
    %Constellation{}
    |> Constellation.changeset(constellation)
    |> Repo.insert(on_conflict: {:replace, [:name, :updated_at, :region_id]}, conflict_target: :constellation_id)
  end
end
