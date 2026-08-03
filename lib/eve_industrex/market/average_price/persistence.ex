defmodule EveIndustrex.Market.AveragePrice.Persistence do
  alias EveIndustrex.Repo
  alias EveIndustrex.Market.AveragePrice
  @moduledoc false
  def upsert_all(list_of_average_prices) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(list_of_average_prices, fn mo ->
        Map.merge(mo, %{
          inserted_at: now,
          updated_at: now
        })
      end)

    Repo.insert_all(
      AveragePrice,
      rows,
      on_conflict: {:replace_all_except, [:type_id, :inserted_at]},
      conflict_target: :type_id
    )
  end
end
