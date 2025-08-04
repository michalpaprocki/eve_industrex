defmodule EveIndustrex.Tasks.CheckTqVersion do
  require Logger
  alias EveIndustrex.Generic
  alias EveIndustrex.Scraper
  use Task

  def start_link(arg) do
    Logger.info("Version check initiated by scheduler...")
    Task.start_link(__MODULE__, :check_latest_game_version, arg)
  end
  def start() do
    Logger.info("Version check initiated manually...")
    task = Task.async(__MODULE__, :check_latest_game_version, [])
    Task.await(task)
  end
  def check_latest_game_version() do
    stored_tq_version = Generic.get_tq_version()
    result = Scraper.get_latest_tq_version()
    case result do
      {:ok, tq_version} ->
        cond do
          stored_tq_version == nil ->
            # this should never match if Task.Init was completed at startup without problems
          {:update, tq_version}
          stored_tq_version.version != tq_version ->
            if String.contains?(tq_version, "expansion") do
              {:run_SDE_update, tq_version}
            else
              {:run_html_parser, tq_version}
            end
          stored_tq_version.version == tq_version ->
            :noop
        end

      {error, reason, url} ->

        {error, reason, url}
    end
  end

end
