defmodule EveIndustrex.Infrastructure.Cache.Loader.ReprocessMaterial do
  alias EveIndustrex.Industry.ReprocessMaterial

  def init() do
    :ets.insert(:reprocess_materials, ReprocessMaterial.Query.for_projection())
  end
end
