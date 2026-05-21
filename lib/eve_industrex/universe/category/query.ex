defmodule EveIndustrex.Universe.Category.Query do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Category
  import Ecto.Query

  def get_categories_for_cache, do: from(c in Category, select: {c.category_id, c.name}) |> Repo.all
end
