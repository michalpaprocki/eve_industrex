defmodule EveIndustrex.Industry.SystemCostIndex.Jobs.SystemCostIndicesProjectionWorker do
  alias EveIndustrex.Infrastructure.ESI.Sync.SyncEvents
  use Oban.Worker, queue: :industry, max_attempts: 10
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Infrastructure.Cache
  alias EveIndustrex.Infrastructure.Readiness
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args, attempt: _attempt}) do
    generation =
      case Cache.get_current_generation(:system_cost_indices) do
        :non_existent ->
          Cache.create_gen(:system_cost_indices)

        gen ->
          gen
      end

    Logger.info("Current_gen for SCI: #{generation}")

    expected_strategies_count = Sync.Query.get_resource_strategies_count("system_cost_indices")

    current_with_status =
      Sync.Query.get_current_resource_generation_and_status(expected_strategies_count.id)

    if expected_strategies_count.count == length(current_with_status) and
         all_generations_completed?(current_with_status) and
         fresh_gen?(generation, current_with_status) do
      Logger.info("Projecting fresh SCIP...")
      new_tid = Cache.create_system_cost_indices_table()

      EveIndustrex.Industry.SystemCostIndex.Service.project_system_cost_indices(new_tid)

      Logger.info(
        "Cache generation before: #{Cache.get_current_generation(:system_cost_indices)}"
      )

      latest_gen =
        current_with_status
        |> Enum.map(&elem(&1, 0))
        |> Enum.max()

      Logger.info("Publishing generation #{latest_gen} for System Cost Indices")
      Cache.update_generation(:system_cost_indices, latest_gen)
      Logger.info("Cache generation after: #{Cache.get_current_generation(:system_cost_indices)}")
      SyncEvents.projection_rebuilt("system_cost_indices")

      if !Readiness.enabled?(:system_cost_index) do
        Readiness.mark_ready(:system_cost_index)
      end
    else
      Logger.info(":noop")
    end

    :ok
  end

  defp all_generations_completed?(generations) do
    Enum.all?(generations, fn {_gen, status} ->
      status == :completed || status == :not_modified
    end)
  end

  defp fresh_gen?(store_gen, fetched_gens) do
    latest_gen =
      fetched_gens
      |> Enum.map(&elem(&1, 0))
      |> Enum.max()

    latest_gen > store_gen
  end
end
