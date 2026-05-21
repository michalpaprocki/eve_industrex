defmodule EveIndustrex.Infrastructure.ESI.Response do
  defstruct [:status, :body, :etag, :expires_at, :pages, :rate_limit]
end
