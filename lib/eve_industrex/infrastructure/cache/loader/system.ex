defmodule EveIndustrex.Infrastructure.Cache.Loader.System do
  alias EveIndustrex.Universe.System.Query
  @moduledoc false
  def init() do
    :ets.insert(:systems, Query.get_systems_for_cache())
  end
end
