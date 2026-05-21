defmodule EveIndustrex.Universe.Region.Persistence do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Region

  def upsert_all(list_of_regions, return? \\ false) when is_list(list_of_regions) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_regions, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      Region,
      rows,
      on_conflict: {:replace, [:name, :description, :updated_at]},
      conflict_target: :region_id,
      returning: return?
    )
  end

  def upsert(region) do
    %Region{}
    |> Region.changeset(region)
    |> Repo.insert(on_conflict: {:replace, [:name, :description, :updated_at]}, conflict_target: :region_id)
  end
end
