defmodule EveIndustrex.Market.AveragePrice.Mapper do

  def from_esi(ap) do
    %{
      type_id: Map.get(ap, "type_id"),
      adjusted_price: Map.get(ap, "adjusted_price"),
      average_price: Map.get(ap, "average_price")
    }
  end
end
