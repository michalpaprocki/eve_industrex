defmodule EveIndustrex.Tasks.Init do
  use Task
  require Logger

  alias EveIndustrex.Utils
  alias EveIndustrex.Generic
  alias EveIndustrex.Scraper


  def start_link(arg) do
    Logger.info("App's data preparation initiated by Supervisor...")
    Task.start_link(__MODULE__, :prep_app_on_startup, arg)
  end
  def prep_app_on_startup() do
    # if Application.get_env(:eve_industrex, :MIX_ENV) == :prod do
      case Generic.get_present_records() do
        {false, counts }->
          Logger.info("Found empty DB rows... fetching SDE")
          Utils.fetch_SDE()
          Logger.info("Populating the DB...")
          Enum.map(counts, fn {schema, count} -> read_out_schema(schema, count) |> Generic.populate_db() end)
          Utils.remove_SDE_files()

          tq_version = Scraper.get_latest_tq_version()
          Generic.upsert_tq_version(tq_version)

        {true} ->
          {:ok, "DB records present..."}
      end
      if !Enum.any?(Supervisor.which_children(EveIndustrex.Supervisor), fn c -> elem(c, 0) == EveIndustrex.ScheduleOverseer end) do

        Supervisor.start_child(EveIndustrex.Supervisor, EveIndustrex.ScheduleOverseer)
        Supervisor.start_child(EveIndustrex.Supervisor, EveIndustrex.Schedulers.TqVersion)
        Supervisor.start_child(EveIndustrex.Supervisor, EveIndustrex.Schedulers.AveragePrice)
        Supervisor.start_child(EveIndustrex.Supervisor, EveIndustrex.Schedulers.ScheduleSupervisor)

      end
    # end
  end
  defp read_out_schema(schema, count) do
    Logger.info("#{count} entries of #{inspect(schema)} found... Updating... ")
    schema
  end
end
