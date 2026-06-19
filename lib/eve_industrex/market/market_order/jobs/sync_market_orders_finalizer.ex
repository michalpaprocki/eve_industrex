defmodule EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersFinalizer do
require Logger
alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator

use Oban.Worker, queue: :market_orders, max_attempts: 10
  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: attempt}) do
    %{"strategy_id" => strategy_id} = args
    Orchestrator.finalize(strategy_id, attempt)
  end

end
