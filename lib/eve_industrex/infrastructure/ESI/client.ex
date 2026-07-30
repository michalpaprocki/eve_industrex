defmodule EveIndustrex.Infrastructure.ESI.Client do
  alias EveIndustrex.Infrastructure.ESI.Endpoints.Category
  alias EveIndustrex.Infrastructure.ESI.Endpoints.Group
  alias EveIndustrex.Infrastructure.ESI.{Headers, Response}
  require Logger

  alias EveIndustrex.Infrastructure.ESI.Endpoints.{
    AveragePrices,
    MarketOrders,
    Station,
    MarketGroup,
    SystemCostIndices,
    Type
  }

  def get_market_orders_route(region_id, page), do: MarketOrders.compose(region_id, page)
  def get_stations_route(station_id), do: Station.compose(station_id)

  def fetch_market_orders(region_id, page, metadata) do
    if page == 1 and not is_nil(metadata.etag) do
      fetch(MarketOrders.compose(region_id, page), metadata.etag)
    else
      fetch(MarketOrders.compose(region_id, page))
    end
  end

  def fetch_type(type_id) do
    fetch(Type.compose(type_id))
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

  def fetch_average_prices(_target_id, _page, metadata) do
    if is_nil(metadata.etag) do
      fetch(AveragePrices.compose())
    else
      fetch(AveragePrices.compose(), metadata.etag)
    end
  end

  def fetch_system_cost_indices(_target_id, _page, metadata) do
    if is_nil(metadata.etag) do
      fetch(SystemCostIndices.compose())
    else
      fetch(SystemCostIndices.compose(), metadata.etag)
    end
  end

  def fetch_group(group_id) do
    fetch(Group.compose(group_id))
  end

  def fetch_category(category_id) do
    fetch(Category.compose(category_id))
  end

  defp fetch(url) do
    case Req.get(url) do
      {:ok,
       %Req.Response{
         status: status,
         headers: headers,
         body: body,
         private: _private,
         trailers: _trailers
       } = _response} ->
        {:ok,
         %Response{
           status: status,
           body: body,
           route: url,
           headers: %Headers{
             global_error_limit_remain: get_header(headers, "x-esi-error-limit-remain"),
             global_error_limit_reset: get_header(headers, "x-esi-error-limit-reset"),
             last_modified: get_header(headers, "last-modified"),
             retry_after: get_header(headers, "retry-after"),
             pages: get_header(headers, "x-pages"),
             etag: get_header(headers, "etag"),
             expires_at: get_header(headers, "expires"),
             rate_limit: get_header(headers, "x-ratelimit-limit"),
             rate_limit_used: get_header(headers, "x-ratelimit-used"),
             rate_limit_remaining: get_header(headers, "x-ratelimit-remaining"),
             rate_limit_group: get_header(headers, "x-ratelimit-group")
           }
         }}

      {:error, exception} ->
        {:error, exception}
    end
  end

  defp fetch(url, etag) do
    req = Req.new(url: url, decode_body: true) |> Req.Request.put_header("if-none-match", etag)

    case Req.request(req) do
      {:ok,
       %Req.Response{
         status: status,
         headers: headers,
         body: body,
         private: _private,
         trailers: _trailers
       } = _response} ->
        {:ok,
         %Response{
           status: status,
           body: body,
           route: url,
           headers: %Headers{
             global_error_limit_remain: get_header(headers, "x-esi-error-limit-remain"),
             global_error_limit_reset: get_header(headers, "x-esi-error-limit-reset"),
             last_modified: get_header(headers, "last-modified"),
             retry_after: get_header(headers, "retry-after"),
             pages: get_header(headers, "x-pages"),
             etag: get_header(headers, "etag"),
             expires_at: get_header(headers, "expires"),
             rate_limit: get_header(headers, "x-ratelimit-limit"),
             rate_limit_used: get_header(headers, "x-ratelimit-used"),
             rate_limit_remaining: get_header(headers, "x-ratelimit-remaining"),
             rate_limit_group: get_header(headers, "x-ratelimit-group")
           }
         }}

      {:error, exception} ->
        {:error, exception}
    end
  end

  defp get_header(headers, key) do
    case Map.get(headers, key) do
      [value | _] ->
        value

      _ ->
        nil
    end
  end
end
