defmodule EveIndustrex.Infrastructure.ESI.Endpoints.AveragePrices do
  @average_market_prices_url "https://esi.evetech.net/latest/markets/prices/?datasource=tranquility"

def compose(), do: @average_market_prices_url
end
