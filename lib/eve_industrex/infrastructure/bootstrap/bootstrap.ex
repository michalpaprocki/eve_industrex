defmodule EveIndustrex.Infrastructure.Bootstrap do
  alias EveIndustrex.Scraper
  alias EveIndustrex.Utils
  alias EveIndustrex.TqVersionService
  alias EveIndustrex.Infrastructure.Bootstrap.Service
  require Logger


  def run do
    seed_if_needed()
    sync_tq_version()
  end

  defp seed_if_needed do
    case Service.get_present_records() do
        {false, counts }->
          Logger.info("Found empty DB rows... fetching SDE")
          Utils.fetch_SDE()
          Logger.info("Populating the DB...")
          Enum.each(counts, fn {schema, count} -> read_out_schema(schema, count) |> Service.populate_db() end)
          Utils.remove_SDE_files()

          tq_version = Scraper.get_latest_tq_version()
          TqVersionService.upsert_tq_version(tq_version)

        {true} ->
          Logger.info("DB records present...")
          :ok
    end
      Logger.info("Populating the Cache...")
      Service.populate_cache()
  end
  defp sync_tq_version do
    tq_version = Scraper.get_latest_tq_version()
    TqVersionService.upsert_tq_version(tq_version)
  end
  defp read_out_schema(schema, count) do
    Logger.info("#{count} entries of #{inspect(schema)} found... Updating... ")
    schema
  end
end
