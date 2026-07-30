defmodule EveIndustrex.Market.AveragePrice.Store do
  def get_count() do
    :ets.tab2list(get_average_prices_table_id()) |> length()
  end

  def get_all() do
    :ets.tab2list(get_average_prices_table_id())
  end

  def get_average_price(type_id) when is_number(type_id) do
    case :ets.lookup(get_average_prices_table_id(), type_id) do
      [{^type_id, _name, average_price, adjusted_price}] ->
        %{
          average_price: average_price,
          adjusted_price: adjusted_price
        }

      [] ->
        %{
          average_price: nil,
          adjusted_price: nil
        }
    end
  end

  def get_average_price(type_id) when is_binary(type_id) do
    type_id = String.to_integer(type_id)

    case :ets.lookup(get_average_prices_table_id(), type_id) do
      [{^type_id, _name, average_price, adjusted_price}] ->
        %{
          average_price: average_price,
          adjusted_price: adjusted_price
        }

      [] ->
        %{
          average_price: nil,
          adjusted_price: nil
        }
    end
  end

  defp get_average_prices_table_id() do
    :persistent_term.get(:average_prices_tid)
  end
end
