defmodule EveIndustrex.Infrastructure.ESI.Sync.MissingTypesWorker do
alias EveIndustrex.Universe
  use Oban.Worker, queue: :esi_general, max_attempts: 10
  alias EveIndustrex.Universe.Type

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args, attempt: _attempt, max_attempts: _max_attempts}) do
    retryables_ap = Oban.Job.query([queue: :average_prices, state: :retryable]) |> Oban.all_jobs()
    discarded_ap = Oban.Job.query([queue: :average_prices, state: :discarded]) |> Oban.all_jobs()
    retryables_mo = Oban.Job.query([queue: :market_orders, state: :retryable]) |> Oban.all_jobs()
    discarded_mo = Oban.Job.query([queue: :market_orders, state: :discarded]) |> Oban.all_jobs()
    overal = retryables_ap ++ discarded_ap ++ retryables_mo ++ discarded_mo

    if length(overal) > 0 do


      missing_types_errors = Enum.map(overal, fn r ->
        Enum.map(r.errors, fn e ->
          e["error"]
        end)
      end) |> List.flatten()

      errored_type_ids = Enum.map(missing_types_errors, fn x -> Regex.run(~r/\(type_id\)=\([0-9]+\) is not present in table/, x) end) |> Enum.uniq() |> List.flatten() |> Enum.filter(fn x -> x != nil end)

      missing_type_ids = Enum.map(errored_type_ids, fn x ->
        Regex.run(~r/[0-9]+/, x)
      end) |> List.flatten()

      Logger.info("Found #{length(missing_type_ids)} missing type_id(s)")

      Enum.each(missing_type_ids, fn t ->
        if !Universe.Type.Query.type_present?(t) do
          Type.Import.type_from_ESI(t)
        end
      end)

      # move this logic to ESI.Sync orchestration pipe later

      # Enum.map(overal, fn x -> Oban.Job.query(id: x.id) end)
      # |> Enum.map(fn x ->
      #     Oban.delete_all_jobs(x)
      # end)

      :ok
    else
    Logger.info("No missing type_ids...")
    :ok
    end
  end
end
