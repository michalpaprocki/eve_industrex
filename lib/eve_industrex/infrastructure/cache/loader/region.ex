defmodule EveIndustrex.Infrastructure.Cache.Loader.Region do
  alias EveIndustrex.Universe.Region.Query
  require Logger
  def init() do
    regions = Query.get_regions_for_cache()
    :ets.insert(:regions, regions)
  end
end
