defmodule EveIndustrex.Market.MarketOrder.Jobs.MarketStoreProjectionWorker do
  alias EveIndustrex.Infrastructure.ESI.Sync.SyncEvents
  use Oban.Worker, queue: :market_orders, max_attempts: 10
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Infrastructure.Cache
  alias EveIndustrex.Infrastructure.Readiness
  require Logger
  @moduledoc false
  @impl Oban.Worker
  def perform(%Oban.Job{args: _args, attempt: _attempt}) do
    Logger.info("current_gen for MO: #{Cache.get_current_generation(:market_orders)}")
    generation = Cache.get_current_generation(:market_orders)

    expected_strategies_count = Sync.Query.get_resource_strategies_count("market_orders")

    current_with_status =
      Sync.Query.get_current_resource_generation_and_status(expected_strategies_count.id)

    if expected_strategies_count.count == length(current_with_status) and
         all_generations_completed?(current_with_status) and
         fresh_gen?(generation, current_with_status) do
      Logger.info("Projecting fresh MOP...")
      new_tid = Cache.create_market_orders_table()
      new_bid_ask_tid = Cache.create_trade_hub_bid_ask_spread_table()
      EveIndustrex.Market.MarketOrder.Service.project_orders_to_cache(new_tid)
      EveIndustrex.Market.MarketOrder.Service.project_bid_ask_for_trade_hub(new_bid_ask_tid)

      Logger.info("Cache generation before: #{Cache.get_current_generation(:market_orders)}")

      latest_gen = generation + 1

      Logger.info("Publishing generation #{latest_gen} for Market Orders")
      Cache.update_generation(:market_orders, latest_gen)
      Logger.info("Cache generation after: #{Cache.get_current_generation(:market_orders)}")
      SyncEvents.projection_rebuilt("market_orders")

      if !Readiness.enabled?(:market_orders) do
        Readiness.mark_ready(:market_orders)
      end
    else
      Logger.info(":noop")
    end

    :ok
  end

  defp all_generations_completed?(generations) do
    Enum.all?(generations, fn {_gen, status} ->
      status == :completed || status == :not_modified
    end)
  end

  defp fresh_gen?(store_gen, fetched_gens) do
    fetched_gens
    |> Enum.map(&elem(&1, 0))
    |> Enum.all?(fn x -> x > store_gen end)
  end
end
