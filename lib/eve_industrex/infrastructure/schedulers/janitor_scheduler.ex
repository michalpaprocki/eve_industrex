defmodule EveIndustrex.Infrastructure.Schedulers.JanitorScheduler do
  use Oban.Worker, queue: :schedulers, unique: [period: :infinity]
    require Logger

    @impl Oban.Worker
    def perform(%Oban.Job{args: _args}) do
      Logger.info("Checking for retryable or discarded jobs...")

      Oban.insert(EveIndustrex.Infrastructure.ESI.Sync.MissingTypesWorker.new(%{}))
      {:snooze, 120}
    end
end
