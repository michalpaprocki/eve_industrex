defmodule EveIndustrex.Infrastructure.Schedulers.StrategyScheduler do
  alias EveIndustrex.Infrastructure.ESI.Sync.SyncEvents
  use Oban.Worker, queue: :schedulers, unique: [period: :infinity]
  require Logger
  alias EveIndustrex.Infrastructure.ESI.Sync.Query
  @moduledoc false
  @workers %{
    "market_orders" => EveIndustrex.Market.MarketOrder.Jobs.SyncMarketOrdersRootWorker,
    "average_prices" => EveIndustrex.Market.AveragePrice.Jobs.SyncAveragePricesWorker,
    "system_cost_indices" =>
      EveIndustrex.Industry.SystemCostIndex.Jobs.SyncSystemCostIndicesWorker
  }

  @impl Oban.Worker
  def perform(_job) do
    {:ok, strats} = Query.claim_due_strategies()

    Enum.map(strats, fn s -> s.resource_type.name end)
    |> Enum.uniq()
    |> Enum.each(fn s -> SyncEvents.sync_started(s) end)

    Logger.info("Got #{inspect(length(strats))} due strats...")

    strats
    |> Enum.each(fn strategy ->
      worker = Map.fetch!(@workers, strategy.resource_type.name)

      %{strategy_id: strategy.id}
      |> worker.new()
      |> Oban.insert()
    end)

    {:snooze, 60}
  end
end
