defmodule EveIndustrex.Infrastructure.Schedulers.ProjectionScheduler do
  alias EveIndustrex.Infrastructure.ESI.Sync.Query
  use Oban.Worker, queue: :schedulers, unique: [period: :infinity]
  require Logger
  @workers %{
    "market_orders" => EveIndustrex.Market.MarketOrder.Jobs.MarketStoreProjectionWorker
  }
  @impl Oban.Worker
  def perform(_) do
    Logger.info("Checking latest generations for cache projection...")
    resources = Query.get_resource_types()
    Enum.map(resources, fn resource ->
      worker = Map.get(@workers, resource.name)
      %{"resource_name" => resource.name}
      |> worker.new()
      |> Oban.insert()
    end)
    {:snooze, 120}
  end
end
