defmodule EveIndustrex.Universe.System.Store do

  def get_all(), do: :ets.tab2list(:systems)

end
