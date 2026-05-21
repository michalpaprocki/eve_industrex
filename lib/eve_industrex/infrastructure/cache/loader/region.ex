defmodule EveIndustrex.Infrastructure.Cache.Loader.Region do
  alias EveIndustrex.Universe.Region.Query
  def init() do
    :ets.insert(:regions, Query.get_regions_for_cache())
  end
end
