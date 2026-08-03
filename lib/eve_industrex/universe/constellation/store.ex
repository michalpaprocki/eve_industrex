defmodule EveIndustrex.Universe.Constellation.Store do
  @moduledoc false
  def get_all(), do: :ets.tab2list(:region_constellations)
end
