defmodule EveIndustrex.Infrastructure.ESI.Endpoints.MarketOrders do
  @moduledoc false
  @market_orders_url "https://esi.evetech.net/latest/markets/"
  # @market_groups_url "https://esi.evetech.net/latest/markets/groups/"
  # @market_statistics_url "https://esi.evetech.net/markets/"
  # https://data.everef.net/structures/structures-latest.v2.json
  def compose(region_id, page) do
    @market_orders_url <>
      ~s"#{region_id}" <>
      "/orders/?datasource=tranquility&order_type=all&page=#{Integer.to_string(page)}"
  end
end
