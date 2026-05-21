defmodule EveIndustrex.Infrastructure.Cache.Loader.Category do
  alias EveIndustrex.Universe.Category.Query
  def init, do: :ets.insert(:categories, Query.get_categories_for_cache)
end
