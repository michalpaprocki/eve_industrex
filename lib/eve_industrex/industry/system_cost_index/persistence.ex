defmodule EveIndustrex.Industry.SystemCostIndex.Persistence do
  alias EveIndustrex.Industry.SystemCostIndex
  alias EveIndustrex.Repo
  @moduledoc false
  def upsert_all(list_of_system_cost_indices, return? \\ false)
      when is_list(list_of_system_cost_indices) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(list_of_system_cost_indices, fn i ->
        Map.merge(i, %{
          inserted_at: now,
          updated_at: now
        })
      end)

    Repo.insert_all(
      SystemCostIndex,
      rows,
      on_conflict: {:replace, [:cost_index]},
      conflict_target: [:system_id, :activity],
      returning: return?
    )
  end
end
