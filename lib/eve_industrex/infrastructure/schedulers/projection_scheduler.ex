defmodule EveIndustrex.Infrastructure.Schedulers.ProjectionScheduler do
  alias EveIndustrex.Infrastructure.ESI.Sync.Query
  use Oban.Worker, queue: :schedulers, unique: [period: :infinity]
  require Logger
  @workers %{
    "market_orders" => EveIndustrex.Market.MarketOrder.Jobs.MarketStoreProjectionWorker,
    "average_prices" => EveIndustrex.Market.AveragePrice.Jobs.AveragePricesStoreProjectionWorker,
    "system_cost_indices" => EveIndustrex.Industry.SystemCostIndex.Jobs.SystemCostIndicesProjectionWorker
  }
  @impl Oban.Worker
  def perform(_) do
    Logger.info("Checking latest generations for cache projection...")
    resources = Query.get_resource_types()
    Enum.map(resources, fn resource ->

      worker = Map.get(@workers, resource.name)

      if is_nil(worker) do
        :noop
      else
        %{"resource_name" => resource.name}
        |> worker.new()
        |> Oban.insert()
      end
      end)
    {:snooze, 120}
  end
end
