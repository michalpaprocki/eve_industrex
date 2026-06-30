defmodule EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersPagesWorker do

alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator

alias EveIndustrex.Infrastructure.ESI.Client
use Oban.Worker, queue: :market_orders, max_attempts: 5


#  move resolution logic to a resolver/finalizer worker - it's too crowded here


require Logger
  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: attempt, max_attempts: max_attempts}) do
    %{"strategy_id" => strategy_id, "generation_id" => generation_id, "page" => page} = args
      case Orchestrator.sync_paginated_resource(strategy_id, generation_id, attempt, max_attempts, &Client.fetch_market_orders/3, page) do
        {:snooze, delay} ->
           Logger.info("Snoozing pages worker")
          {:snooze, delay}
        :ok ->

          :ok
      end
  end

end
