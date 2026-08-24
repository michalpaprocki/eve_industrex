defmodule EveIndustrex.Universe.Group.Store do
  @moduledoc false
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

  def get_published_group_by_category(category_id) do
    case :ets.match_object(:category_groups, {category_id, :_, :_, true}) do
      [] ->
        nil

      groups ->
        Enum.map(groups, fn {category_id, group_id, name, _published} ->
          %{category_id: category_id, group_id: group_id, name: name}
        end)
    end
  end

  def get_published_group(group_id) do
    case :ets.match_object(:category_groups, {:_, group_id, :_, true}) do
      [{category_id, group_id, name, _published}] ->
        %{category_id: category_id, group_id: group_id, name: name}

      [] ->
        nil
    end
  end

  def get_group(group_id) do
    case :ets.match_object(:category_groups, {:_, group_id, :_, :_}) do
      [{category_id, group_id, name, _published}] ->
        %{category_id: category_id, group_id: group_id, name: name}

      [] ->
        nil
    end
  end
end
