defmodule EveIndustrex.Industry.SystemCostIndex.Jobs.SyncSystemCostIndicesFinalizer do
  alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator

  use Oban.Worker, queue: :industry, max_attempts: 10
  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: attempt, max_attempts: max_attempts}) do
    %{"strategy_id" => strategy_id} = args
    Orchestrator.finalize(strategy_id, attempt, max_attempts)
  end
end
