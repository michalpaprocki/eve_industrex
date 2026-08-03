defmodule EveIndustrex.Industry.SystemCostIndex.Service do
  alias EveIndustrex.Industry.SystemCostIndex

  alias EveIndustrex.Repo
  import Ecto.Query
  require Logger

  @moduledoc """
    Projects SCI to :ets table.
  """
  def project_system_cost_indices(tid) do
    query =
      from(sci in SystemCostIndex,
        select: %{
          cost_index: sci.cost_index,
          activity: sci.activity,
          system_id: sci.system_id
        }
      )

    {ms, _result} =
      :timer.tc(fn ->
        Repo.transaction(
          fn ->
            Repo.stream(query)
            |> Stream.map(&to_ets_row/1)
            |> Stream.chunk_every(5000)
            |> Stream.each(&:ets.insert(tid, &1))
            |> Stream.run()
          end,
          timeout: :infinity
        )
      end)

    Logger.info("System Cost Indices Projection took #{ms / 1_000_000}s pid=#{inspect(self())} ")
    old_tid = :persistent_term.get(:system_cost_indices_tid)

    :persistent_term.put(:system_cost_indices_tid, tid)

    :ets.delete(old_tid)
  end

  defp to_ets_row(system_cost_index) do
    {
      {system_cost_index.system_id, system_cost_index.activity},
      {system_cost_index.cost_index}
    }
  end
end
