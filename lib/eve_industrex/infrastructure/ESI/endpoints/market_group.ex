defmodule EveIndustrex.Infrastructure.ESI.Endpoints.MarketGroup do

  @market_group_url "https://esi.evetech.net/markets/groups/"

  def get_market_group_url(), do: @market_group_url
  def compose(market_group_id) when is_number(market_group_id) do
    @market_group_url<>Integer.to_string(market_group_id)
  end
  def compose(market_group_id) when is_binary(market_group_id) do
    @market_group_url<>market_group_id
  end
end
