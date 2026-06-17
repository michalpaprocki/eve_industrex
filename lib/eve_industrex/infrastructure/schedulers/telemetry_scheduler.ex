defmodule EveIndustrex.Infrastructure.Schedulers.TelemetryScheduler do
    use Oban.Worker, queue: :schedulers, unique: [period: :infinity]
  require Logger


    @impl Oban.Worker
    def perform(_) do
      failed_and_critical = EveIndustrex.Infrastructure.ESI.Sync.Query.get_failed_and_critical_strategies()
      if length(failed_and_critical) > 0 do

        Enum.map(failed_and_critical, fn fic ->
          Logger.warning("Found failed or critical job: #{inspect(fic.id)}")
        end)
      else
        Logger.info("No failed or critical jobs found.")
      end
      {:snooze, 1800}
    end
end
