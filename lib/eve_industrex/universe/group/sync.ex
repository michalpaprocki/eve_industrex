defmodule EveIndustrex.Universe.Group.Sync do
  alias EveIndustrex.Infrastructure.ESI.Client

  def fetch_from_ESI(group_id) do
    case Client.fetch_market_group(group_id) do
      {:ok, response} ->
        {:ok, response}

      {:error, exception} ->
        {:error, exception}
    end
  end
end
