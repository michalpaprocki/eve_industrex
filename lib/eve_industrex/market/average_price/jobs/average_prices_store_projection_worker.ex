defmodule EveIndustrex.Market.AveragePrice.Jobs.AveragePricesStoreProjectionWorker do
  use Oban.Worker, queue: :average_prices, max_attempts: 10
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Infrastructure.Cache
  alias EveIndustrex.Infrastructure.Readiness
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args, attempt: _attempt}) do

    generation =
      case Cache.get_current_generation(:average_prices) do
        :non_existent ->
          Cache.create_gen(:average_prices)
        gen ->
          gen
      end
    Logger.info("Current_gen for AP: #{generation}")

    expected_strategies_count = Sync.Query.get_resource_strategies_count("average_prices")
    current_with_status = Sync.Query.get_current_resource_generation_and_status(expected_strategies_count.id)

     if expected_strategies_count.count == length(current_with_status) and all_generations_completed?(current_with_status) and fresh_gen?(generation, current_with_status) do
          Logger.info("Projecting fresh APP...")
          new_tid = Cache.create_average_prices_table()

          EveIndustrex.Market.AveragePrice.Service.project_average_prices(new_tid)


          Logger.info("Cache generation before: #{Cache.get_current_generation(:average_prices)}")

          latest_gen =
            current_with_status
            |> Enum.map(&elem(&1, 0))
            |> Enum.max()
          Logger.info("Publishing generation #{latest_gen} for Average Prices")
          Cache.update_generation(:average_prices, latest_gen)
          Logger.info("Cache generation after: #{Cache.get_current_generation(:average_prices)}")
           if !Readiness.enabled?(:average_prices) do
            Readiness.mark_ready(:average_prices)
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
    latest_gen =
      fetched_gens
      |> Enum.map(&elem(&1, 0))
      |> Enum.max()

      latest_gen > store_gen
  end
end
