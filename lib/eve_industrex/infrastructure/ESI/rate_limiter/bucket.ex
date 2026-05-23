defmodule EveIndustrex.Infrastructure.ESI.RateLimiter.Bucket do
  defstruct [:limit, :remaining, :updated_at, :cost, :group_penalty_cost]
  alias EveIndustrex.Infrastructure.ESI.Headers
  alias EveIndustrex.Infrastructure.ESI.RateLimiter.Penalty
  def reserve(%__MODULE__{} = bucket) do
    bucket
    |> Map.update(:remaining, bucket.remaining, fn rem -> rem - bucket.group_penalty_cost end)
    |> Map.replace(:updated_at, DateTime.utc_now())
  end

  def new(%Headers{} = headers) do
    %__MODULE__{
      limit: parse_limit(headers.rate_limit),
      remaining: String.to_integer(headers.rate_limit_remaining),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
      cost: String.to_integer(headers.rate_limit_used),
      group_penalty_cost: Penalty.get_group(headers.rate_limit_group)
    }
  end
  defp parse_limit(nil), do: nil
  defp parse_limit(limit) do
    [capacity, window] = String.split(limit, "/")
    %{
      capacity: String.to_integer(capacity),
      window: parse_window(window)
    }
  end
  defp parse_window("15m"), do: 900
end
