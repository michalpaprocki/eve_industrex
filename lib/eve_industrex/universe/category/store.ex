defmodule EveIndustrex.Universe.Category.Store do

  def get_categories, do: :ets.tab2list(:categories)

  def exists?(category_id) do
    :ets.member(:categories, category_id)
  end
  def add(category) when is_tuple(category) do
    :ets.insert(:categories, category)
  end
  def filter_known(category_ids) do
    Enum.filter(category_ids, fn id ->
      exists?(id)
    end)
  end
  def filter_unknown(category_ids) do
    Enum.filter(category_ids, fn id ->
      !exists?(id)
    end)
  end
  def get_category(category_id)  do
    case :ets.lookup(:categories, category_id) do
      [{^category_id, name, _published}] ->
        %{category_id: category_id, name: name}
    end
  end
end
