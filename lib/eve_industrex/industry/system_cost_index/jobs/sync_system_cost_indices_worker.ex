defmodule EveIndustrex.Industry.SystemCostIndex.Jobs.SyncSystemCostIndicesWorker do
  require Logger
  use Oban.Worker, queue: :industry, max_attempts: 10
  alias EveIndustrex.Infrastructure.ESI.Client
  alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator
  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: attempt, max_attempts: max_attempts}) do
    Logger.info("System Cost Indices Sync Running...")
    %{"strategy_id" => strategy_id} = args

    case Orchestrator.initiate_resource_sync(
           strategy_id,
           attempt,
           max_attempts,
           &Client.fetch_system_cost_indices/3
         ) do
      {:snooze, delay} ->
        Logger.info("Snoozing #{__MODULE__}")
        {:snooze, delay}

      :ok ->
        :ok
    end

    EveIndustrex.Industry.SystemCostIndex.Jobs.SyncSystemCostIndicesFinalizer.new(%{
      "strategy_id" => strategy_id
    })
    |> Oban.insert()
  end
end
