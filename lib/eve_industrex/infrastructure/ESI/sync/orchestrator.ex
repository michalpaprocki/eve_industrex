defmodule EveIndustrex.Infrastructure.ESI.Sync.Orchestrator do

  alias EveIndustrex.Infrastructure.ESI.Sync.OrchestratorService

  alias EveIndustrex.Infrastructure.ESI.RouteGroups
  alias EveIndustrex.Infrastructure.ESI.EtagStore
  alias EveIndustrex.Infrastructure.ESI.RateLimiter


  alias EveIndustrex.Infrastructure.ESI.Sync
  require Logger

  def initiate_paginated_resource_sync(strategy_id, attempt, fetch_fn) do

strategy = Sync.Query.get_strategy(strategy_id)

    rate_limit_group = RouteGroups.get(strategy.resource_type.name)

    case RateLimiter.available?(rate_limit_group) do
      true ->
        metadata = EtagStore.get_metadata(rate_limit_group, strategy.target_id)




          generation = OrchestratorService.prepare_generation(strategy.id, strategy.target_id, strategy.next_generation)

          case OrchestratorService.orchestrate(fetch_fn, generation.id, strategy.next_generation, attempt, strategy, metadata, 1) do
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
          :unknown ->
            :discover
          end
  end
  def sync_paginated_resource(strategy_id, generation_id, attempt, fetch_fn, page) do

      strategy = Sync.Query.get_strategy(strategy_id)
      rate_limit_group = RouteGroups.get(strategy.resource_type.name)

      case RateLimiter.available?(rate_limit_group) do
        true ->
          metadata = EtagStore.get_metadata(rate_limit_group, strategy.target_id)

          case OrchestratorService.orchestrate(fetch_fn, generation_id, strategy.next_generation, attempt, strategy, metadata, page) do
            {:snooze, delay} ->
              {:snooze, delay}

            :ok ->
              :ok
          end
      false ->
        Logger.error("postpone from ratelimiter")
        # make it dynamic based on budget / refill pace
        {:snooze, OrchestratorService.calc_delay(attempt)}
      :unknown ->
        :discover
      end
  end
  def finalize(strategy_id, attempt) do
       strategy = Sync.Query.get_strategy_with_generation(strategy_id)

       generation = Enum.at(strategy.generations, 0)

       case generation.status do
        :running  ->
          if generation.pages_completed != generation.pages_total do
            {:snooze, OrchestratorService.calc_delay(attempt)}
          else
            Logger.info("Finalizer complete after snooze")
            OrchestratorService.update_generation(generation.id, %{
                    status: :completed,
                    finished_at: OrchestratorService.now(),
                    }
                  )
            OrchestratorService.finalize_strategy(strategy, %{
            status: :idle,
            next_generation: strategy.next_generation + 1,
            last_successful_sync: OrchestratorService.now(),
            next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at)
            })
            # OrchestratorService.delete_orders_from_prev_generations(generation.generation)
            :ok
          end
        :completed ->
           Logger.info("Finalizer complete")
          OrchestratorService.finalize_strategy(strategy, %{
            status: :idle,
            next_generation: strategy.next_generation + 1,
            last_successful_sync: OrchestratorService.now(),
            next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at)
            })
            # OrchestratorService.delete_orders_from_prev_generations(generation.generation)
            :ok
        :critical ->
           Logger.error("Finalizer critical")
           OrchestratorService.finalize_strategy(strategy, %{
            status: :critical,
            next_generation: strategy.next_generation + 1,
            next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at),
            enabled: false
            })
          :ok
        _ ->
           Logger.warning("default case resolution")
          if generation.pages_total == generation.pages_completed do
              Logger.warning(":idle - pages completed")
            OrchestratorService.finalize_strategy(strategy, %{
              status: :idle,
              next_generation: strategy.next_generation + 1,
              last_successful_sync: OrchestratorService.now(),
              next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at)
              })

              :ok

          else
              Logger.warning(":failed")
             OrchestratorService.finalize_strategy(strategy, %{
              status: :failed,
              next_generation: strategy.next_generation + 1,
              next_run_at: OrchestratorService.calc_next_run(strategy.sync_interval_seconds, generation.started_at)
              })
              :ok
          end
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
