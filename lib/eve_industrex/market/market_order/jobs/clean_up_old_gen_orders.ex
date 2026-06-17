defmodule EveIndustrex.Market.MarketOrder.Jobs.CleanUpOldGenOrders do
alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator
  use Oban.Worker, queue: :market_orders, max_attempts: 10

  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: attempt}) do
    %{"strategy_id" => strategy_id} = args
      Orchestrator.clean_up_prev_gen_targets(strategy_id, attempt, &EveIndustrex.Market.MarketOrder.Persistence.delete_all_from_prev_gen/2)
  end
end
