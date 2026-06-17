defmodule EveIndustrex.Infrastructure.Schedulers.StrategyCleanUpScheduler do
      use Oban.Worker, queue: :schedulers, unique: [period: :infinity]
  require Logger


    @impl Oban.Worker
    def perform(_) do
      Logger.info("Running clean up for strategies...")
      strategies = EveIndustrex.Infrastructure.ESI.Sync.Query.get_strategies()
        Enum.map(strategies, fn strategy ->
          EveIndustrex.Market.MarketOrder.Jobs.CleanUpOldGenOrders.new(%{strategy_id: strategy.id})
        end)
          |> Oban.insert_all()
      {:snooze, 7200}
    end
end
