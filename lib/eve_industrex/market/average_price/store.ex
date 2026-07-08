defmodule EveIndustrex.Market.AveragePrice.Store do

 def get_count() do
    :ets.tab2list(get_average_prices_table_id()) |>  length()
  end
  def get_all() do
    :ets.tab2list(get_average_prices_table_id())
  end

   defp get_average_prices_table_id() do
    :persistent_term.get(:average_prices_tid)
  end
end
