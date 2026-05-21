defmodule EveIndustrex.Universe.Category.Store do

  def get_categories, do: :ets.tab2list(:categories)
end
