defmodule EveIndustrex.Infrastructure.Cache.Loader.Group do
  alias EveIndustrex.Universe.Group.Query
  def init, do: :ets.insert(:category_groups, Query.get_groups_for_cache)
end
