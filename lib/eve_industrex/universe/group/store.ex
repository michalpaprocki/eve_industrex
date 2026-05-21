defmodule EveIndustrex.Universe.Group.Store do

  def get_groups, do: :ets.tab2list(:category_groups)
end
