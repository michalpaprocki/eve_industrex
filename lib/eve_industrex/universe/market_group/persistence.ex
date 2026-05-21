defmodule EveIndustrex.Universe.MarketGroup.Persistence do
  alias EveIndustrex.Universe.MarketGroup
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.MarketGroup.Query

  def upsert_all(list_of_market_groups, return? \\ false) when is_list(list_of_market_groups) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_market_groups, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      MarketGroup,
      rows,
      on_conflict: {:replace, [:description, :name, :parent_group_id, :updated_at]},
      conflict_target: :market_group_id,
      returning: return?
    )
  end

  def upsert(market_group) do
    %MarketGroup{}
    |> MarketGroup.changeset(market_group)
    |> Repo.insert(on_conflict: {:replace, [:description, :name, :parent_group_id, :updated_at]}, conflict_target: :market_group_id)
  end

  # run to create market_group assocs
  def put_mg_assocs() do
    market_groups = Query.get_market_groups_with_parents()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, market_groups, fn mg ->
      parent = Query.get_market_group(mg.parent_group_id) |> Repo.preload([:types, :child_market_group, :parent_market_group])
      parent
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:child_market_group, [mg | parent.child_market_group])
      |> Repo.update()

    end) |> Enum.to_list
  end
end
