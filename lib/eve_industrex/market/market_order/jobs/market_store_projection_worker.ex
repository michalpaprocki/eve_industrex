defmodule EveIndustrex.Market.MarketOrder.Jobs.MarketStoreProjectionWorker do

  use Oban.Worker, queue: :market_orders, max_attempts: 10
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Infrastructure.Cache
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args, attempt: _attempt}) do
    %{"resource_name" => resource_name} = args
    case Cache.get_current_generation(:market_orders) do
      :non_existent ->
        Logger.info("Projecting init...")
        new_tid = Cache.create_market_orders_table()
        new_bid_ask_tid = Cache.create_trade_hub_bid_ask_spread_table()
        EveIndustrex.Market.MarketOrder.Service.project_orders_to_cache(new_tid)
        EveIndustrex.Market.MarketOrder.Service.project_bid_ask_for_trade_hub(new_bid_ask_tid)
        current_gen = EveIndustrex.Infrastructure.ESI.Sync.Query.get_current_gen(resource_name)
        Cache.update_generation(:market_orders, current_gen)

        generation ->

        expected_strategies_count = Sync.Query.get_resource_strategies_count("market_orders")
        current_with_status = Sync.Query.get_current_resource_generation_and_status(expected_strategies_count.id)

        if expected_strategies_count.count == length(current_with_status) and all_generations_completed?(current_with_status) and fresh_gen?(generation, current_with_status) do
         Logger.info("Projecting fresh...")
          new_tid = Cache.create_market_orders_table()
          new_bid_ask_tid = Cache.create_trade_hub_bid_ask_spread_table()
          EveIndustrex.Market.MarketOrder.Service.project_orders_to_cache(new_tid)
          EveIndustrex.Market.MarketOrder.Service.project_bid_ask_for_trade_hub(new_bid_ask_tid)
          current_gen = EveIndustrex.Infrastructure.ESI.Sync.Query.get_current_gen(resource_name)

          Cache.update_generation(:market_orders, current_gen)
        else
          Logger.info(":noop")

        end
    end
    :ok
  end

  defp all_generations_completed?(generations) do
    Enum.all?(generations, fn {_gen, status} ->
      status == :completed
    end)
  end
  defp fresh_gen?(store_gen, fetched_gens) do
    latest_gen =
      fetched_gens
      |> Enum.map(&elem(&1, 0))
      |> Enum.max()

      latest_gen > store_gen
  end
end
