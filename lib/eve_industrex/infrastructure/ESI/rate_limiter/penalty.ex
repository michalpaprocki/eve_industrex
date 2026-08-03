defmodule EveIndustrex.Infrastructure.ESI.RateLimiter.Penalty do
  @moduledoc false
  # hardcoded for now might be good idea to keep it somewhere persistent
  def get_group("market-order"), do: 5
end
