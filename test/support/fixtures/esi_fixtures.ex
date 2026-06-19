defmodule EveIndustrex.Test.EsiFixtures do
  alias EveIndustrex.Infrastructure.ESI.Sync

  def resource_type_fixture() do
    %Sync.ResourceType{}
    |> Sync.ResourceType.changeset(%{name: "test_resource"})
    |> Sync.Persistence.insert_resource_type()

  end
  def strategy_fixture(resource_id) do
    %Sync.EsiSyncStrategy{}
    |> Sync.EsiSyncStrategy.changeset(Sync.SyncProvider.default_market_order_strategy(1, resource_id))
    |> Sync.Persistence.insert_strategy()
    |> EveIndustrex.Repo.preload(:resource_type)
  end
  def generation_fixture(strategy_id) do
     now = DateTime.utc_now() |> DateTime.truncate(:second)
     {:ok, gen} =
        %Sync.EsiSyncGeneration{}
        |> Sync.EsiSyncGeneration.changeset(%{generation: 1 ,esi_sync_strategy_id: strategy_id, started_at: now, target_id: 1, status: :running, pages_completed: 0})
        |> Sync.Persistence.insert_generation()
        gen
  end


end
