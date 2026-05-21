defmodule EveIndustrex.Universe.System.Store do

  def get_all, do: :ets.tab2list(:constellation_systems)
end
