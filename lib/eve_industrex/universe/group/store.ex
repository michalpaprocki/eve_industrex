defmodule EveIndustrex.Universe.Group.Store do

  def get_groups(), do: :ets.tab2list(:category_groups)
  def exists?(group_id) do
    case :ets.match_object(:category_groups, {:_, group_id, :_}) do
      [{_, ^group_id, _}] ->
        true
      [] ->
        false
    end
  end
  def add(group) when is_tuple(group) do
    :ets.insert(:category_groups, group)
  end
  def filter_unknown(ids) do
    Enum.filter(ids, fn id ->
      !exists?(id)
    end)
  end
  def get_group(group_id) do
    case :ets.match_object(:category_groups, {:_, group_id, :_}) do
      [{category_id, group_id, name}] ->
        %{category_id: category_id, group_id: group_id, name: name}
      [] ->
        nil
    end
  end
end
