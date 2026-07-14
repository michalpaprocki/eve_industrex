defmodule EveIndustrex.Infrastructure.Schedulers.StrategyScheduler do

  use Oban.Worker, queue: :schedulers, unique: [period: :infinity]
  require Logger
  alias EveIndustrex.Infrastructure.ESI.Sync.Query

  @workers %{
    "market_orders" => EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersRootWorker,
    "average_prices" => EveIndustrex.Market.AveragePrice.Jobs.SyncAveragePricesWorker,
    "system_cost_indices" => EveIndustrex.Industry.SystemCostIndex.Jobs.SyncSystemCostIndicesWorker

  }

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Strategy scheduler running...")
    {:ok, strats} = Query.claim_due_strategies()
    Logger.info("Got #{inspect(length(strats))} due strats...")
    strats
    |> Enum.map(fn strategy ->
     worker = Map.fetch!(@workers, strategy.resource_type.name)

        %{strategy_id: strategy.id}
        |> worker.new()
        |> Oban.insert()  end)

    {:snooze, 60}
  end

end
