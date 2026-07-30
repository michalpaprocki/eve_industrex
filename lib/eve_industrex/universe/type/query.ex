defmodule EveIndustrex.Universe.Type.Query do
  alias EveIndustrex.Universe.Category
  alias EveIndustrex.Universe.Group
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Repo
  import Ecto.Query
  def get_type(type_id), do: Repo.get_by(Type, type_id: type_id)
  def get_types(), do: Repo.all(Type)

  def get_types_ids(list_of_type_ids),
    do:
      from(t in Type,
        order_by: [asc: :type_id],
        where: t.type_id in ^list_of_type_ids,
        select: t.type_id
      )
      |> Repo.all()

  def get_type_by_name(name), do: Repo.get_by(Type, name: name)

  def get_types_by_name(query),
    do: from(t in Type, where: ilike(t.name, ^"%#{query}%") and t.published == true) |> Repo.all()

  def get_published_types_with_details() do
    from(t in Type,
      join: g in Group,
      on: t.group_id == g.group_id,
      join: c in Category,
      on: g.category_id == c.category_id,
      select:
        {t.type_id,
         %{
           type_id: t.type_id,
           description: t.description,
           mass: t.mass,
           name: t.name,
           packaged_volume: t.packaged_volume,
           volume: t.volume,
           category_id: g.category_id,
           category: c.name,
           group: g.name,
           published: t.published
         }}
    )
    |> Repo.all()
  end

  def return_missing_types(list_of_types_ids) do
    query =
      from(
        v in fragment("SELECT * FROM unnest(?::integer[]) AS type_id", ^list_of_types_ids),
        left_join: t in Type,
        on: t.type_id == v.type_id,
        where: is_nil(t.type_id),
        select: v.type_id
      )

    Repo.all(query)
  end

  def type_present?(type_id) do
    from(t in Type, where: t.type_id == ^type_id) |> Repo.exists?()
  end

  def get_newest() do
    Type
    |> last(:inserted_at)
    |> Repo.all()
  end

  def get_type_ids_for_index() do
    from(t in Type, select: {t.type_id, true}) |> Repo.all()
  end
end
