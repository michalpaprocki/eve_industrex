defmodule EveIndustrex.Universe.Region.Store do

  def get_all(), do: :ets.tab2list(:regions)
  def get_ids(), do: get_all() |> Enum.map(fn {id, _name} -> id end)
end
