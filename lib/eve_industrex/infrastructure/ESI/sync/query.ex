defmodule EveIndustrex.Infrastructure.ESI.Sync.Query do
  alias EveIndustrex.Infrastructure.ESI.Sync.RateLimitGroup
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncGeneration
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncCache
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy
  alias EveIndustrex.Infrastructure.ESI.Sync.ResourceType
  alias EveIndustrex.Repo
  import Ecto.Query
  @resources ["market_orders"]

  def get_initial_resources(), do: @resources
  def get_resource_types_count() do
    Repo.aggregate(ResourceType, :count, :id)
  end
  def get_strategies_count(list_of_resource_type_ids) do
      query = from(r in EsiSyncStrategy, where: r.resource_type_id in ^list_of_resource_type_ids, select: {r.resource_type_id, count(r.id)}, group_by: r.resource_type_id)
      Repo.all(query)
      |> Enum.map(fn {id, count} ->
        %{resource_type_id: id, count: count}
      end)
  end
  def get_resource_strategies_count(name) do
    from(r in ResourceType, where: r.name == ^name, select: %{id: r.id, count: r.strategies_count}) |> Repo.one
  end
  def aggregate_strats_count(resource_id) do
    from(s in EsiSyncStrategy, where: s.resource_type_id == ^resource_id) |> Repo.aggregate(:count)
  end
  def get_generation(gen_id) do
    Repo.get(EsiSyncGeneration, gen_id)
  end
  def get_generations() do
    Repo.all(EsiSyncGeneration)
  end
  def get_strat_by_target_id(target_id) do
    Repo.get_by(EsiSyncStrategy, target_id: target_id)
  end
  def get_generations_with_pages() do
    Repo.all(EsiSyncGeneration) |> Repo.preload(:generation_pages)
  end
  def get_resource_types() do
    Repo.all(ResourceType)
  end
  def get_strategies() do
    Repo.all(EsiSyncStrategy)
  end
  def get_strategy(id) do
    Repo.get(EsiSyncStrategy, id) |> Repo.preload(:resource_type)
  end
  def get_running_strategies() do
    from(s in EsiSyncStrategy, where: s.status == :running) |> Repo.all
  end
  def get_scheduled_strategies() do
    from(s in EsiSyncStrategy, where: s.status == :scheduled) |> Repo.all
  end
  def get_strategy_with_generation(id) do
    gen_query = from(g in EsiSyncGeneration, order_by: [desc: g.generation], limit: 1)
    from(s in EsiSyncStrategy, where: s.id == ^id, preload: :resource_type)
    |> Repo.one()
    |> Repo.preload(generations: gen_query, generations: [:generation_pages])
  end
  def claim_due_strategies() do
    now = DateTime.utc_now()
    Repo.transaction(fn ->
      strategies = from(s in EsiSyncStrategy,
        where: s.enabled == true and s.status in [:failed, :idle] and s.next_run_at <= ^now, lock: "FOR UPDATE SKIP LOCKED") |> Repo.all |> Repo.preload(:resource_type)

      ids = Enum.map(strategies, &(&1.id))

      from(s in EsiSyncStrategy, where: s.id in ^ids) |> Repo.update_all(set: [status: :scheduled])
      strategies
    end)
  end
  def get_failed_and_critical_strategies() do
    from(strat in EsiSyncStrategy, where: strat.status == :critical and strat.status == :failed and strat.enabled == true, select: %{id: strat.id}) |> Repo.all
  end
  def get_total_execution_time() do
    from(gen in EsiSyncGeneration, order_by: [gen.updated_at], limit: 1, select: gen.duration_ms) |> Repo.all
  end
  def get_caches(), do: Repo.all(EsiSyncCache)
  def get_sync_cache(strategy_id, page) do
    # from(s in EsiSyncStrategy, joinwhere: strategy_id == ^id )
  end
   def get_missing_rate_limit_groups() do

    from(s in EsiSyncStrategy, left_join: g in assoc(s, :rate_limit_group), where: is_nil(g.id), preload: [:resource_type]) |> Repo.all |> Enum.map(fn strat ->
      strat.resource_type.name
    end) |> Enum.uniq()
  end
    def get_current_resource_generation_and_status(resource_id) do
    max_gen = from(g in EsiSyncGeneration, select: max(g.generation))
    from(s in EsiSyncStrategy, where: s.resource_type_id == ^resource_id, join: g in EsiSyncGeneration, on: s.id == g.esi_sync_strategy_id, where: g.generation == subquery(max_gen), select: {g.generation, g.status}) |> Repo.all
  end
    def get_current_gen(resource_name) do
    gen_query = from(g in EsiSyncGeneration, order_by: [desc: g.generation], limit: 1)
    from(r in ResourceType, where: r.name == ^resource_name, join: s in EsiSyncStrategy, on: r.id == s.resource_type_id, join: g in subquery(gen_query), on: s.id == g.esi_sync_strategy_id,
      where: g.status == :completed, select: g.generation, limit: 1) |> Repo.one
  end
end
