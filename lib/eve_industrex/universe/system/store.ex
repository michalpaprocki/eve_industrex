defmodule EveIndustrex.Universe.System.Store do
  @moduledoc false
  def get_all(), do: :ets.tab2list(:systems)
end
