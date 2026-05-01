defmodule EveIndustrex.Tasks.Update do
  require Logger
  alias EveIndustrex.BootstrapService
  alias EveIndustrex.Schemas.TqVersion
  alias EveIndustrex.TqVersionService
  alias EveIndustrex.Market
  alias EveIndustrex.Scraper

  alias EveIndustrex.Utils
  use Task
  def start_link_from_SDE(arg) do
    Logger.info("Update initiated by Supervisor...")
    Task.start_link(__MODULE__, :from_sde, arg)
  end
  def start_from_SDE() do
    Logger.info("Update initiated manually...")
    task = Task.async(__MODULE__, :from_sde, [])
    Task.await(task)
  end
   def start_link_average_prices(arg) do
    Logger.info("Update initiated by Supervisor...")
    Task.start_link(__MODULE__, :average_prices, arg)
  end
  def start_average_prices() do
    Logger.info("Update initiated manually...")
    task = Task.async(__MODULE__, :average_prices, [])
    Task.await(task)
  end
  # this needs better error handling instead of raising exceptions
  def from_SDE() do
    tq_version = Scraper.get_latest_tq_version()
    populate_from_SDE()
    TqVersionService.upsert_tq_version(tq_version)
    :ok
  end
  def from_SDE(tq_version) do
    # populate_from_SDE()
    TqVersionService.upsert_tq_version(tq_version)
    :ok
  end
  defp populate_from_SDE() do
    case Utils.fetch_SDE() do
      :ok ->
        Enum.map(BootstrapService.get_used_schemas(), fn schema -> BootstrapService.populate_db(schema) end)
        Utils.remove_SDE_files()
      {:error, {error, reason, url}} ->
        {:error, {error, reason, url}}
    end
  end
  def average_prices() do
    Market.update_market_average_prices()
  end
  def market_orders(region_id) do
    Market.update_market_orders(region_id)
  end
  def market_statistics(region_id, list_of_type_ids) do
    Market.update_market_statistics(region_id, list_of_type_ids)
  end
end
