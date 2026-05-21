defmodule EveIndustrex.Universe.Type.Query do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Repo
  import Ecto.Query
  def get_type(type_id), do: Repo.get_by(Type, type_id: type_id)
  def get_types(), do: Repo.all(Type)
  def get_types_ids(list_of_type_ids), do: from(t in Type, order_by: [asc: :type_id], where: t.type_id in ^list_of_type_ids, select: t.type_id) |> Repo.all()
  def get_type_by_name(name), do: Repo.get_by(Type, name: name)
  def get_types_by_name(query), do: from(t in Type, where: ilike(t.name, ^"%#{query}%") and t.published == true)  |> Repo.all

end
