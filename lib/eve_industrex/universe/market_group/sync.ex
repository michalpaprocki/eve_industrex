defmodule EveIndustrex.Universe.MarketGroup.Sync do
  alias EveIndustrex.Infrastructure.ESI.ClientContext
  alias EveIndustrex.Infrastructure.ESI.Client
  def get_market_groups() do
    case Client.fetch_market_groups() do
      {:ok, response} ->
        {:ok, response.body}
      {:error, exception} ->
        {:error, exception}
    end
  end

  def update_from_esi(market_group_ids) do
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, market_group_ids, fn market_group_id ->
      Client.fetch_market_group(market_group_id)
    end) |> Enum.map(fn {:ok, data} -> data end) |> Enum.map(fn {:ok, response} -> response.body end)
  end
end
