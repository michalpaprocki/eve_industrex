defmodule EveIndustrex.Infrastructure.Cache.Loader.System do
  alias EveIndustrex.Universe.System.Query
  def init() do
    :ets.insert(:systems, Query.get_systems_for_cache())
  end
end
