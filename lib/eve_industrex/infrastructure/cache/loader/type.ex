defmodule EveIndustrex.Infrastructure.Cache.Loader.Type do
  alias EveIndustrex.Universe.Type.Query
  def init() do
    :ets.insert(:types, Query.get_published_types_with_details())
  end
end
