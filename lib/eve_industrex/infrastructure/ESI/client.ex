defmodule EveIndustrex.Infrastructure.ESI.Client do
  alias EveIndustrex.Infrastructure.ESI.Response

  def fetch(url) do
    case Req.get(url) do
      {:ok, %Req.Response{status: status, headers: headers, body: body, private: _private, trailers: _trailers} = _response} ->
        %Response{status: status, body: body, pages: Map.get(headers, "x-pages", nil), etag: Map.get(headers, "etag", nil), expires_at: Map.get(headers, "expires", nil), rate_limit: Map.get(headers, "x-ratelimit-limit", nil)}
      {:error, exception} ->
        exception
    end
  end

end
