defmodule EveIndustrex.Infrastructure.Cache.Loader.Constellation do
  alias EveIndustrex.Universe.Constellation.Query

  def init() do
    :ets.insert(:region_constellations, Query.get_constellations_for_cache())
  end
end
