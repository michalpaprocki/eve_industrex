defmodule EveIndustrex.Infrastructure.ESI.Sync.Orchestrator do

  alias EveIndustrex.Infrastructure.ESI.Sync.SyncEvents
  alias EveIndustrex.Infrastructure.ESI.Sync.OrchestratorService
  alias EveIndustrex.Infrastructure.ESI.RouteGroups
  alias EveIndustrex.Infrastructure.ESI.RateLimiter


  alias EveIndustrex.Infrastructure.ESI.Sync
  require Logger

  def initiate_paginated_resource_sync(strategy_id, attempt, max_attempts, fetch_fn) do

    strategy = Sync.Query.get_strategy(strategy_id)

    rate_limit_group = RouteGroups.get(strategy.resource_type.name)

    case RateLimiter.available?(rate_limit_group) do
      true ->
        metadata = %{etag: strategy.last_etag, expires_at: strategy.last_expires_at}


          generation = OrchestratorService.prepare_generation(strategy.id, strategy.target_id, strategy.next_generation)

          case OrchestratorService.orchestrate(fetch_fn, generation.id, strategy.next_generation, attempt, max_attempts, strategy, metadata, 1) do
            {:snooze, delay} ->
              Logger.warning("job snoozed")
              {:snooze, delay}

            {:fanout, pages} ->
              {:fanout, pages, generation.id}

            {:ok, pages, generation_id}->
              {:ok, pages, generation_id}
            :ok ->
              :ok
          end


          false ->
            Logger.error("postpone from ratelimiter")
            # make it dynamic based on budget / refill pace
            {:snooze, OrchestratorService.calc_delay(attempt)}
          end
  end
  def sync_paginated_resource(strategy_id, generation_id, attempt, max_attempts, fetch_fn, page) do

      strategy = Sync.Query.get_strategy(strategy_id)
      generation = Sync.Query.get_generation(generation_id)
      rate_limit_group = RouteGroups.get(strategy.resource_type.name)

      case RateLimiter.available?(rate_limit_group) do
        true ->
          metadata = %{etag: generation.snapshot_etag, expires_at: generation.snapshot_expires_at}

          case OrchestratorService.orchestrate(fetch_fn, generation_id, strategy.next_generation, attempt, max_attempts, strategy, metadata, page) do
            {:snooze, delay} ->
              {:snooze, delay}

            :ok ->
              :ok
          end
      false ->
        Logger.error("postpone from ratelimiter")
        # make it dynamic based on budget / refill pace
        {:snooze, OrchestratorService.calc_delay(attempt)}

      end
  end
  def finalize(strategy_id, attempt, max_attempts) do
       strategy = Sync.Query.get_strategy_with_generation(strategy_id)

       generation = Enum.at(strategy.generations, 0)

       case generation.status do
        :running  ->
          cond do
            generation.pages_completed == generation.pages_total ->
              Logger.info("Completed in #{inspect(attempt)} attempts / #{inspect(max_attempts)}")
              OrchestratorService.update_generation(generation.id, %{
                status: :completed,
                finished_at: OrchestratorService.now()
                })
                Logger.info("Finalizer complete - strategy done")
                SyncEvents.generation_completed(generation, strategy)
            OrchestratorService.finalize_strategy(strategy, %{
              last_modified: generation.snapshot_last_modified,
              status: :idle,
              next_generation: strategy.next_generation + 1,
              last_etag: generation.snapshot_etag,
              last_expires_at: generation.snapshot_expires_at,
              last_successful_sync: OrchestratorService.now(),
              next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at)
              })
              :ok
            true ->
              Logger.info("Finalizer snoozing")
            {:snooze, OrchestratorService.calc_delay(attempt)}
          end

        :completed ->
          SyncEvents.generation_completed(generation, strategy)
           Logger.info("Finalizer complete - strategy done")
          OrchestratorService.finalize_strategy(strategy, %{
            last_modified: generation.snapshot_last_modified,
            status: :idle,
            next_generation: strategy.next_generation + 1,
            last_etag: generation.snapshot_etag,
            last_expires_at: generation.snapshot_expires_at,
            last_successful_sync: OrchestratorService.now(),
            next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at)
            })

            :ok
        :not_modified ->
           Logger.info("Finalizer complete - not modified")
           SyncEvents.generation_not_modified(generation, strategy)
          OrchestratorService.finalize_strategy(strategy, %{
            status: :idle,
            next_generation: strategy.next_generation + 1,
            last_successful_sync: OrchestratorService.now(),
            next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at)
            })

            :ok
        :superseded ->
          Logger.error("Finalizer done - dataset invalid")
          SyncEvents.generation_superseded(generation, strategy)
           OrchestratorService.finalize_strategy(strategy, %{
            last_modified: generation.snapshot_last_modified,
            status: :idle,
            next_generation: strategy.next_generation,
            next_run_at: OrchestratorService.now(),
            enabled: false
            })
          :ok
        :critical ->
           Logger.error("Finalizer critical")
           SyncEvents.generation_critical(generation, strategy)
           OrchestratorService.finalize_strategy(strategy, %{
            status: :critical,
            next_generation: strategy.next_generation + 1,
            next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at),
            enabled: false
            })
          :ok
        :failed ->
          Logger.error("Finalizer failure")
           SyncEvents.generation_failed(generation, strategy)
           OrchestratorService.finalize_strategy(strategy, %{
            status: :failed,
            next_generation: strategy.next_generation + 1,
            next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at),
            enabled: false
            })
          :ok

       end
  end
  def clean_up_prev_gen_targets(strategy_id, _attempt, clean_up_fun) do
    strategy = Sync.Query.get_strategy(strategy_id)
    if strategy.next_generation == 1 do
      :ok
    else
      clean_up_fun.(strategy.target_id, strategy.next_generation - 1)
      :ok
    end
  end
end
