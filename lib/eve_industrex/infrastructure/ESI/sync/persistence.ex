defmodule EveIndustrex.Infrastructure.ESI.Sync.Persistence do

  alias EveIndustrex.Infrastructure.ESI.Sync.RateLimitGroup
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncGeneration
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncCache
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy
  alias EveIndustrex.Repo
  alias EveIndustrex.Infrastructure.ESI.Sync.ResourceType
  import Ecto.Query
  import Ecto.Changeset
  def delete_resources() do
    Repo.delete_all(ResourceType)
  end
  def delete_strategies() do
    Repo.delete_all(EsiSyncStrategy)
  end
  def delete_generations() do
    Repo.delete_all(EsiSyncGeneration)
  end
  def delete_caches() do
    Repo.delete_all(EsiSyncCache)
  end
  def delete_all() do
    delete_caches()
    delete_generations()
    delete_strategies()
    delete_resources()
  end
  def insert_all_resource_types(list_of_resource_types) do
    Repo.insert_all(
      ResourceType,
      Enum.map(list_of_resource_types, fn rt ->
        rt
      end)
    )
  end
  def update_resource_type_strategies_count(id, count) do
    Repo.get(ResourceType, id)
    |> ResourceType.update_strategies_count_changeset(count)
    |> Repo.update()
  end
  def upsert_strategies(list_of_strategies) do
    now = get_now()
    timestamps = %{
      updated_at: now,
      inserted_at: now
    }
    rows = Enum.map(list_of_strategies, fn s ->
      Map.merge(timestamps, s)
    end)

    Repo.insert_all(
      EsiSyncStrategy,
      rows,
      on_conflict: {:replace_all_except, [:inserted_at, ]},
      conflict_target: [:resource_type_id, :target_id]
    )

  end
  def update_strategy(strategy) do
    Repo.update(strategy)
  end
  def insert_generation(generation) do
    Repo.transaction(fn ->
    strategy_id = Ecto.Changeset.get_field(generation, :esi_sync_strategy_id)
     query = from(s in EsiSyncStrategy, where: s.status == :scheduled and s.id == ^strategy_id)
      Repo.update_all(query, set: [status: :running])

      Repo.insert!(generation)

        end)
  end
  def upsert_generation(generation) do
    Repo.transaction(fn ->
    strategy_id = Ecto.Changeset.get_field(generation, :esi_sync_strategy_id)
     query = from(s in EsiSyncStrategy, where: s.status == :scheduled and s.id == ^strategy_id)
      Repo.update_all(query, set: [status: :running])

      Repo.insert!(generation, on_conflict:
      from(e in EsiSyncGeneration,
      update: [
        set: [
          priority: fragment("EXCLUDED.priority"),
          started_at: fragment("EXCLUDED.started_at"),
          finished_at: fragment("EXCLUDED.finished_at"),
          updated_at: fragment("EXCLUDED.updated_at"),
          duration_ms: fragment("EXCLUDED.duration_ms"),
          last_error: fragment("EXCLUDED.last_error")
          ],
          inc: [generation: 1]
          ]),
          conflict_target: [:esi_sync_strategy_id, :target_id])

        end)
  end
  def mark_as_strategy_completed(strategy_id, status) do

    Repo.get!(EsiSyncStrategy, strategy_id)
    |> EsiSyncStrategy.changeset(%{status: status})
    |> Repo.update()

  end
  def update_generation(generation) do
    Repo.update(generation)
  end
  def increment_generation_pages_completed(generation_id, total_pages) do
    from(g in EsiSyncGeneration, where: g.id == ^generation_id)
    |> Repo.update_all(inc: [pages_completed: 1], set: [pages_total: total_pages])
  end
  def upsert_sync_generation_page(page) do
    Repo.insert(page, on_conflict: :replace_all, conflict_target: [:esi_sync_generation_id, :page_number])
  end
  defp get_now() do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
  def upsert_rate_limit_group(rate_limit_group) do
    Repo.insert(rate_limit_group, on_conflict: :replace_all, conflict_target: [:esi_sync_strategy_id])
  end

end
