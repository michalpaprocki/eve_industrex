defmodule EveIndustrex.Universe.Group.Persistence do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Group

    def upsert_all(list_of_groups, return? \\ false) when is_list(list_of_groups) do
    Repo.insert_all(
      Group,
      Enum.map(list_of_groups, fn c ->
        c
      end),
      on_conflict: {:replace, [:name, :published, :category_id]},
      conflict_target: :group_id,
      returning: return?
    )
  end

  def upsert(group) do
    %Group{}
    |> Group.changeset(group)
    |> Repo.insert(on_conflict: {:replace, [:name, :published, :category_id]}, conflict_target: :group_id)
  end
end
