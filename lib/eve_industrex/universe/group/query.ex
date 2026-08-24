defmodule EveIndustrex.Universe.Group.Query do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Group
  import Ecto.Query
  @moduledoc false
  def get_groups_for_cache,
    do: from(g in Group, select: {g.category_id, g.group_id, g.name, g.published}) |> Repo.all()

  def get_groups, do: from(g in Group) |> Repo.all()

  def return_missing_groups(list_of_group_ids) do
    query =
      from(
        v in fragment("SELECT * FROM unnest(?::integer[]) AS group_id", ^list_of_group_ids),
        left_join: g in Group,
        on: g.group_id == v.group_id,
        where: is_nil(g.group_id),
        select: v.group_id
      )

    Repo.all(query)
  end
end
