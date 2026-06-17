defmodule EveIndustrex.Market.MarketOrder.Mapper do
alias EveIndustrex.Universe.Region
alias EveIndustrex.Universe.Constellation
alias EveIndustrex.Universe.System
  def from_esi(data, generation, region_id) do
    %{
      duration: Map.get(data,"duration"),
      is_buy_order: Map.get(data,"is_buy_order"),
      issued: from_iso(Map.get(data,"issued")),
      location_id: Map.get(data,"location_id"),
      min_volume: Map.get(data, "min_volume"),
      order_id: Map.get(data, "order_id"),
      price: Map.get(data, "price"),
      range: Map.get(data, "range"),
      system_id: Map.get(data, "system_id"),
      type_id: Map.get(data, "type_id"),
      volume_remain: Map.get(data, "volume_remain"),
      volume_total: Map.get(data, "volume_total"),
      generation: generation,
      region_id: region_id
    }
  end
  defp from_iso(data) do
    {:ok, date, _x} = DateTime.from_iso8601(data)
    date
  end

end
