defmodule EveIndustrex.SearchStore do
  def save(object) do
    list = get()

    list =
      if length(list) > 10 do
        [object | list |> Enum.reverse() |> List.delete_at(0) |> Enum.reverse()]
      else
        [object | list]
      end
      |> Enum.uniq()

    :ets.insert(:latest_searched_items, {:latest, list})
  end

  def get() do
    case :ets.lookup(:latest_searched_items, :latest) do
      [{:latest, list}] ->
        list

      [] ->
        []
    end
  end

  def delete() do
    :ets.delete_all_objects(:latest_searched_items)
  end
end
