defmodule EveIndustrex.Universe.Group.Query do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Group
  import Ecto.Query

  def get_groups_for_cache, do: from(g in Group, select: {g.category_id, g.group_id, g.name}) |> Repo.all
  def get_groups, do: from(g in Group) |> Repo.all
end
