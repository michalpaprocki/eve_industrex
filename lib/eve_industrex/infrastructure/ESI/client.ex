defmodule EveIndustrex.Infrastructure.ESI.Client do
  alias EveIndustrex.Infrastructure.ESI.{Headers, Response}
  require Logger
  alias EveIndustrex.Infrastructure.ESI.Endpoints.{MarketOrders, Station, MarketGroup}
  def get_market_orders_route(region_id, page), do: MarketOrders.compose(region_id, page)
  def get_stations_route(station_id), do: Station.compose(station_id)
  def fetch_market_orders(region_id, page, :not_found) do

    fetch(MarketOrders.compose(region_id, page))
  end
  def fetch_market_orders(region_id, page, metadata) do

    if is_nil(metadata.etag) do
      fetch(MarketOrders.compose(region_id, page))
    else
      fetch(MarketOrders.compose(region_id, page), metadata.etag)
    end
  end
  def fetch_station(station_id) do
    fetch(Station.compose(station_id))
  end
  def fetch_market_groups() do
    fetch(MarketGroup.get_market_group_url())
  end
  def fetch_market_group(market_group_id) do
    fetch(MarketGroup.compose(market_group_id))
  end
  defp fetch(url) do

    case Req.get(url) do
      {:ok, %Req.Response{status: status, headers: headers, body: body, private: _private, trailers: _trailers} = _response} ->

        {:ok, %Response{status: status, body: body, route: url, headers: %Headers{retry_after: get_header(headers, "retry-after") ,pages: get_header(headers, "x-pages"), etag: get_header(headers, "etag"), expires_at: get_header(headers, "expires"), rate_limit: get_header(headers, "x-ratelimit-limit"), rate_limit_used: get_header(headers, "x-ratelimit-used"), rate_limit_remaining: get_header(headers, "x-ratelimit-remaining"), rate_limit_group: get_header(headers, "x-ratelimit-group")}}}

      {:error, exception} ->
        {:error, exception}
    end
  end
  defp fetch(url, etag) do

    req = Req.new(url: url, decode_body: true) |> Req.Request.put_header("if-none-match", etag)


    case Req.request(req) do

     {:ok, %Req.Response{status: status, headers: headers, body: body, private: _private, trailers: _trailers} = response} ->

      {:ok, %Response{status: status, body: body, route: url, headers: %Headers{retry_after: get_header(headers, "retry-after") ,pages: get_header(headers, "x-pages"), etag: get_header(headers, "etag"), expires_at: get_header(headers, "expires"), rate_limit: get_header(headers, "x-ratelimit-limit"), rate_limit_used: get_header(headers, "x-ratelimit-used"), rate_limit_remaining: get_header(headers, "x-ratelimit-remaining"), rate_limit_group: get_header(headers, "x-ratelimit-group")}}}

    {:error, exception} ->
        {:error, exception}
    end
  end
  defp get_header(headers, key) do
    case Map.get( headers, key) do
      [value | _] ->
        value
      _-> nil
    end
  end
end
