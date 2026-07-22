defmodule EveIndustrex.Universe.Category.Query do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Category
  import Ecto.Query

  def get_categories_for_cache, do: from(c in Category, select: {c.category_id, c.name, c.published}) |> Repo.all
  def get_unpublished() do
    from(c in Category, where: c.published == false) |> Repo.all()
  end
end
