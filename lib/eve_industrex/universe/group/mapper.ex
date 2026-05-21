defmodule EveIndustrex.Universe.Group.Mapper do

  def from_dump(data) do
    %{
      category_id: Map.get(data, "categoryID"),
      group_id: Map.get(data, "_key"),
      name: Map.get(Map.get(data, "name"), "en"),
      published: Map.get(data, "published")
    }
  end
  def from_esi(data) do
    %{
      category_id: Map.get(data, "category_id"),
      group_id: Map.get(data, "group_id"),
      name: Map.get(data, "name"),
      published: Map.get(data, "published")
    }
  end
end
