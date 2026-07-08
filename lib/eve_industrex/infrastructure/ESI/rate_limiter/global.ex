defmodule EveIndustrex.Infrastructure.ESI.RateLimiter.Global do
  defstruct [:error_limit_remain, :error_limit_reset, :updated_at, :cooldown_until]
  alias EveIndustrex.Infrastructure.ESI.Headers

  def new(%Headers{} = headers, cooldown \\ nil) do
    %__MODULE__{
      error_limit_remain: String.to_integer(headers.global_error_limit_remain),
      error_limit_reset: String.to_integer(headers.global_error_limit_reset),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
      cooldown_until: cooldown
    }
  end
end
