defmodule EveIndustrex.Infrastructure.ESI.RateLimiter.Bucket do
  defstruct [:limit, :remaining, :updated_at, :cooldown_until]
  alias EveIndustrex.Infrastructure.ESI.Headers

  def new(%Headers{} = headers, cooldown \\ nil) do
    %__MODULE__{
      limit: parse_limit(headers.rate_limit),
      remaining: String.to_integer(headers.rate_limit_remaining),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
      cooldown_until: cooldown
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
