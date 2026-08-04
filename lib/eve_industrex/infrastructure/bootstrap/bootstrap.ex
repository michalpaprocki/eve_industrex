defmodule EveIndustrex.Infrastructure.Bootstrap do
  alias EveIndustrex.Infrastructure.Schedulers
  alias EveIndustrex.Scraper
  alias EveIndustrex.Utils
  alias EveIndustrex.TqVersionService
  alias EveIndustrex.Infrastructure.Bootstrap.Service
  alias EveIndustrex.Infrastructure.Readiness
  require Logger
  # TODO maybe make it a worker so it can retry on failure
  @moduledoc """
    Bootstraping - makes sure that all necessary app data is loaded, generates sync strates, populates the SDE caches and starts schedulers.
  """
  def run do
    seed_if_needed()
    sync_tq_version()
    start_scheduler()
  end

  defp seed_if_needed do
    case Service.get_present_records() do
      {false, counts} ->
        Logger.info("Found empty DB rows... fetching SDE")
        Utils.fetch_sde()
        Logger.info("Populating the DB...")

        Enum.each(counts, fn {schema, count} ->
          read_out_schema(schema, count) |> Service.populate_db()
        end)

        Utils.remove_sde_files()

        tq_version = Scraper.get_latest_tq_version()
        TqVersionService.upsert_tq_version(tq_version)
        Readiness.mark_ready(:bootstrap)

      {true} ->
        Logger.info("DB records present...")
        Readiness.mark_ready(:bootstrap)
        :ok
    end

    Logger.info("Populating the Cache...")

    with :ok <- Service.populate_cache() do
      Logger.info("Caches warmed...")
      Readiness.mark_ready(:sde_cache)
      :ok
    end
  end

  defp sync_tq_version do
    {:ok, tq_version} = Scraper.get_latest_tq_version()
    TqVersionService.upsert_tq_version(tq_version)
  end

  defp read_out_schema(schema, count) do
    Logger.info("#{count} entries of #{inspect(schema)} found... Updating... ")
    schema
  end

  defp start_scheduler() do
    if Service.resources_missing?() do
      Logger.info("ESI Resources missing... Populating...")
      Service.put_resources()
    end

    Logger.info("Checking for Resources Strategies...")
    Service.maybe_allocate_strategies()

    Schedulers.StrategyScheduler.new(%{}) |> Oban.insert()
    Schedulers.ProjectionScheduler.new(%{}) |> Oban.insert()
    Schedulers.TelemetryScheduler.new(%{}) |> Oban.insert()
    Schedulers.StrategyCleanUpScheduler.new(%{}) |> Oban.insert()
    # Schedulers.JanitorScheduler.new(%{}) |> Oban.insert()
  end
end
