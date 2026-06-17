defmodule EveIndustrex.Universe.System.Store do

  def get_all(), do: :ets.tab2list(:systems)
  def get_system(system_id) do
    # case :ets.match()
  end
end
