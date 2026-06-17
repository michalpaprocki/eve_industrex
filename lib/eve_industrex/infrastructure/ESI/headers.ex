defmodule EveIndustrex.Infrastructure.ESI.Headers do
  defstruct [:etag, :expires_at, :pages, :rate_limit, :rate_limit_used, :rate_limit_remaining, :rate_limit_group, :retry_after]
end
