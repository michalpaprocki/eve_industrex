defmodule EveIndustrex.Infrastructure.ESI.Endpoints.MarketOrders do
  @market_orders_url "https://esi.evetech.net/latest/markets/"
  @market_groups_url "https://esi.evetech.net/latest/markets/groups/"
  @average_market_prices_url "https://esi.evetech.net/latest/markets/prices/?datasource=tranquility"
  @market_statistics_url "https://esi.evetech.net/markets/"
  def compose(region_id, page) do
    @market_orders_url<>~s"#{region_id}"<>"/orders/?datasource=tranquility&order_type=all&page=#{Integer.to_string(page)}"
  end
end
