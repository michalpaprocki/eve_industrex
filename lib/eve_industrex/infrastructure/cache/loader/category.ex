defmodule EveIndustrex.Infrastructure.Cache.Loader.Category do
  alias EveIndustrex.Universe.Category.Query
  @moduledoc false
  def init, do: :ets.insert(:categories, Query.get_categories_for_cache())
end
