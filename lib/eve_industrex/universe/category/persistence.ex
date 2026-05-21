defmodule EveIndustrex.Universe.Category.Persistence do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Category

  def upsert_all(list_of_categories, return? \\ false) when is_list(list_of_categories) do
    Repo.insert_all(
      Category,
      Enum.map(list_of_categories, fn c ->
        c
      end),
      on_conflict: {:replace, [:name, :published]},
      conflict_target: :category_id,
      returning: return?
    )
  end

  def upsert(category) do
    %Category{}
    |> Category.changeset(category)
    |> Repo.insert(on_conflict: {:replace, [:name, :published]}, conflict_target: :category_id)
  end
end
