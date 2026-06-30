defmodule EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersFinalizer do
require Logger
alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator

use Oban.Worker, queue: :market_orders, max_attempts: 10
  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: attempt, max_attempts: max_attempts}) do
    %{"strategy_id" => strategy_id} = args
    Orchestrator.finalize(strategy_id, attempt, max_attempts)
  end

end
