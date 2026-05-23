defmodule EveIndustrex.Infrastructure.ESI.Client do
  alias EveIndustrex.Infrastructure.ESI.{Headers, Response}

  alias EveIndustrex.Infrastructure.ESI.Endpoints.MarketOrders
  def get_market_orders_route(region_id, page), do: MarketOrders.compose(region_id, page)
  def fetch_market_orders(region_id, page, :not_found) do
    fetch(MarketOrders.compose(region_id, page))
  end
  def fetch_market_orders(region_id, page, etag) do
    fetch(MarketOrders.compose(region_id, page), etag)
  end
  defp fetch(url) do
    case Req.get(url) do
      {:ok, %Req.Response{status: status, headers: headers, body: body, private: _private, trailers: _trailers} = _response} ->

        %Response{status: status, body: body, route: url, headers: %Headers{pages: get_header(headers, "x-pages"), etag: get_header(headers, "etag"), expires_at: get_header(headers, "expires"), rate_limit: get_header(headers, "x-ratelimit-limit"), rate_limit_used: get_header(headers, "x-ratelimit-used"), rate_limit_remaining: get_header(headers, "x-ratelimit-remaining"), rate_limit_group: get_header(headers, "x-ratelimit-group")}}

      {:error, exception} ->
        exception
    end
  end
  defp fetch(url, etag) do
    req = Req.Request.new(url) |> Req.Request.put_header("if-none-match", etag)
    case Req.run(req) do
      {:ok, %Req.Response{status: status, headers: headers, body: body, private: _private, trailers: _trailers} = _response} ->

        %Response{status: status, body: body, route: url, headers: %Headers{pages: get_header(headers, "x-pages"), etag: get_header(headers, "etag"), expires_at: get_header(headers, "expires"), rate_limit: get_header(headers, "x-ratelimit-limit"), rate_limit_used: get_header(headers, "x-ratelimit-used"), rate_limit_remaining: get_header(headers, "x-ratelimit-remaining"), rate_limit_group: get_header(headers, "x-ratelimit-group")}}

      {:error, exception} ->
        exception
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
