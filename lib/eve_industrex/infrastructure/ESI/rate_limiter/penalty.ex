defmodule EveIndustrex.Infrastructure.ESI.RateLimiter.Penalty do
  # hardcoded for now might be good idea to keep it somewhere persistent
  def get_group("market-order"), do: 5
end
