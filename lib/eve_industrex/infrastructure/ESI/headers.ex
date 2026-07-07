defmodule EveIndustrex.Infrastructure.ESI.Headers do
  defstruct [:etag, :expires_at, :pages, :rate_limit, :rate_limit_used, :rate_limit_remaining, :rate_limit_group, :retry_after, :last_modified, :global_error_limit_remain, :global_error_limit_reset]
end
