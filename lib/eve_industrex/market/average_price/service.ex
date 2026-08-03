defmodule EveIndustrex.Market.AveragePrice.Service do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Market.AveragePrice

  alias EveIndustrex.Repo
  import Ecto.Query
  require Logger

  @moduledoc """
    Projects ap to :ets table.
  """
  def project_average_prices(tid) do
    subquery = from(t in Type, where: t.published == true)

    query =
      from(ap in AveragePrice,
        join: t in subquery(subquery),
        on: ap.type_id == t.type_id,
        select: %{
          type_id: ap.type_id,
          adjusted_price: ap.adjusted_price,
          average_price: ap.average_price,
          name: t.name
        }
      )

    {ms, _result} =
      :timer.tc(fn ->
        Repo.transaction(
          fn ->
            Repo.stream(query)
            |> Stream.map(&to_ets_ap_row/1)
            |> Stream.chunk_every(5000)
            |> Stream.each(&:ets.insert(tid, &1))
            |> Stream.run()
          end,
          timeout: :infinity
        )
      end)

    Logger.info("Average Price Projection took #{ms / 1_000_000}s pid=#{inspect(self())} ")
    old_tid = :persistent_term.get(:average_prices_tid)

    :persistent_term.put(:average_prices_tid, tid)

    :ets.delete(old_tid)
  end

  defp to_ets_ap_row(average_price) do
    {average_price.type_id, average_price.name, average_price.average_price,
     average_price.adjusted_price}
  end
end
