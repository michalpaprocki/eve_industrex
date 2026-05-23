defmodule EveIndustrex.Infrastructure.ESI.Sync.Query do
  alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy
  alias EveIndustrex.Infrastructure.ESI.Sync.ResourceType
  alias EveIndustrex.Repo
  import Ecto.Query
  @resources ["market_orders"]

  def get_initial_resources(), do: @resources
  def get_resource_types_count() do
    Repo.aggregate(ResourceType, :count, :id)
  end
  def get_strategies_count(list_of_resource_type_ids) do
      query = from(r in EsiSyncStrategy, where: r.resource_type_id in ^list_of_resource_type_ids, select: {r.resource_type_id, count(r.id)}, group_by: r.resource_type_id)
      Repo.all(query)
      |> Enum.map(fn {id, count} ->
        %{resource_type_id: id, count: count}
      end)
  end
  def get_resource_types() do
    Repo.all(ResourceType)
  end
  def get_strategies() do
    Repo.all(EsiSyncStrategy)
  end
end
