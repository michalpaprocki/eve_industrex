defmodule EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersRootWorker do
alias EveIndustrex.Infrastructure.ESI.Sync.OrchestratorService
alias EveIndustrex.Infrastructure.ESI.Client

alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator
require Logger
use Oban.Worker, queue: :market_orders, max_attempts: 5


# maybe check etag store for expires_at and start job right after expiry to prevent esi cache refresh during job
  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: attempt}) do
    %{"strategy_id" => strategy_id} = args

      case Orchestrator.initiate_paginated_resource_sync(strategy_id, attempt, &Client.fetch_market_orders/3) do
        {:snooze, delay} ->
          Logger.info("Snoozing root worker")
          {:snooze, delay}

        {:fanout, pages, generation_id} ->
          Logger.info("Root worker fanning out")
        jobs =
          Enum.map(2..pages, fn p ->
            EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersPagesWorker.new(%{
              strategy_id: strategy_id,
              generation_id: generation_id,
              page: p
              })
            end)
            Oban.insert_all(jobs)
          :ok

        {:ok, pages, generation_id} ->
          Logger.info("Root worker done without fanout")
          OrchestratorService.update_generation(generation_id, %{
          status: :completed,
          finished_at: OrchestratorService.now(),
          pages_total: pages,
          pages_completed: pages
          }
        )

          :ok
        :ok ->
          Logger.error("should neveeeeeeeeeeeeeeeeeeeeeeeer run")
          :ok
      end



          EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersFinalizer.new(%{"strategy_id" => strategy_id}) |> Oban.insert()
        end
      end
