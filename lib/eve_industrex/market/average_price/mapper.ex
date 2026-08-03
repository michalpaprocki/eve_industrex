defmodule EveIndustrex.Market.AveragePrice.Mapper do
  @moduledoc false
  def from_esi(ap) do
    %{
      type_id: Map.get(ap, "type_id"),
      adjusted_price: Map.get(ap, "adjusted_price"),
      average_price: Map.get(ap, "average_price")
    }
  end
end
