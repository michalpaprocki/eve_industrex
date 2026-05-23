defmodule EveIndustrex.Infrastructure.ESI.Sync.Persistence do

  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy
  alias EveIndustrex.Repo
  alias EveIndustrex.Infrastructure.ESI.Sync.ResourceType
  def delete_resources() do
    Repo.delete_all(ResourceType)
  end
  def delete_strategies() do
    Repo.delete_all(EsiSyncStrategy)
  end
  def insert_all_resource_types(list_of_resource_types) do
    Repo.insert_all(
      ResourceType,
      Enum.map(list_of_resource_types, fn rt ->
        rt
      end)
    )
  end
  def update_resource_type_strategies_count(id, count) do
    Repo.get(ResourceType, id)
    |> ResourceType.update_strategies_count_changeset(count)
    |> Repo.update()
  end
  def upsert_strategies(list_of_strategies) do
    now = %{
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
    rows = Enum.map(list_of_strategies, fn s ->
      Map.merge(now, s)
    end)

    Repo.insert_all(
      EsiSyncStrategy,
      rows,
      on_conflict: {:replace_all_except, [:target_id, :resource_type_id]},
      conflict_target: [:resource_type_id, :target_id]
    )
  end
end
