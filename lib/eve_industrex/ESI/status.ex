defmodule EveIndustrex.ESI.Status do
  @status_url "https://esi.evetech.net/status.json"
  def get_routes_status() do
    case Req.get(@status_url) do
      {:ok, %Req.Response{} = response} ->
        {:ok, response.body, response.headers}
      {:error, exception} ->
        {:error, {:req_exception, exception.reason, @status_url}}
    end
  end
end
