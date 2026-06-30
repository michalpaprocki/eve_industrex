defmodule Infrastructure.ESI.Sync.OrchestratorTest do
alias EveIndustrex.Infrastructure.ESI.RateLimiter
alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncStrategy
  use EveIndustrex.DataCase
  use ExUnit.Case
  alias EveIndustrex.Infrastructure.ESI.Headers
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Infrastructure.ESI.Response
  alias EveIndustrex.Infrastructure.ESI.Sync.Orchestrator
  alias EveIndustrex.Infrastructure.ESI.RouteGroups
  alias EveIndustrex.Infrastructure.ESI.EtagStore
  import EveIndustrex.Test.EsiFixtures

  describe "initiate_paginated_resource_sync/4" do
    setup  do
      resource_type = resource_type_fixture("orchestrator_test_resource")
      strategy = strategy_fixture(resource_type.id)
      # generation = generation_fixture(strategy.id)
      {:ok, %{resource_type: resource_type, strategy: strategy}}
    end

    test "creates a new generation for a 1 pagesync op, stores snapshot etag and expires_at, returns :ok, amount of pages completed and generation id", %{resource_type: _resource_type, strategy: strategy} do
      result = Orchestrator.initiate_paginated_resource_sync(strategy.id ,0, 5, fetch_fn(esi_response(200, [], "1", "test_etag")))
      gen_id =  elem(result, 2)
      strategy_updated = get_strategy_with_gens(strategy.id)
      {gen, gen_page} = get_generation(gen_id, 1)
      assert {:ok, 1, gen_id} == result
      assert gen.status == :running
      assert gen.pages_completed == 1
      assert gen.pages_total == 1
      assert gen.snapshot_etag == "test_etag"
      assert gen_page.page_number == 1
      assert gen_page.status == :completed

    end
    test "creates a new generation for a multi page sync op, stores snapshot etag and expires_at, returns :fanout page number and generation id", %{resource_type: _resource_type, strategy: strategy} do
      result = Orchestrator.initiate_paginated_resource_sync(strategy.id ,0, 5, fetch_fn(esi_response(200, [], "20", "test_etag")))
      gen_id =  elem(result, 2)

      strategy_updated = get_strategy_with_gens(strategy.id)
      {gen, gen_page} = get_generation(gen_id, 1)
      assert {:fanout, 20, gen_id} == result
      assert gen.status == :running
      assert gen.pages_completed == 1
      assert gen.pages_total == 20
      assert gen.snapshot_etag == "test_etag"
      assert gen_page.page_number == 1
      assert gen_page.status == :completed

    end
  end
  describe "sync_paginated_resource/6" do

    setup  do
      resource_type = resource_type_fixture("orchestrator_test_resource")
      strategy = strategy_fixture(resource_type.id)
      generation = generation_fixture(strategy.id)
      {:ok, %{resource_type: resource_type, strategy: strategy, generation: generation}}
    end

    test "proceeds with syncing page 2 out of 3, returns :ok, increments pages completed", %{resource_type: _resource_type, strategy: strategy, generation: generation} do
        Ecto.Changeset.change(generation, %{snapshot_last_modified: DateTimeParser.parse_datetime!("Fri, 19 Jun 2026 07:31:36 GMT", to_utc: true)|> DateTime.from_naive!("Etc/UTC")|>DateTime.truncate(:second)})
        |> Repo.update
      assert :ok ==Orchestrator.sync_paginated_resource(strategy.id, generation.id, 1, 5, fetch_fn(esi_response(200, [], "3")), "2")
      {gen, _gen_page} = get_generation(generation.id, 2)

      assert gen.pages_completed == 1
      assert gen.pages_total == 3
      assert gen.status == :running
    end
  end
  describe "finalize/3" do
    setup  do
      resource_type = resource_type_fixture("orchestrator_test_resource")
      strategy = strategy_fixture(resource_type.id)
      generation = generation_fixture(strategy.id)
      {:ok, %{resource_type: resource_type, strategy: strategy, generation: generation}}
    end
    test "finalizes a strategy when number of pages completed is equal to pages total", %{resource_type: resource_type, strategy: strategy, generation: generation} do
        changeset =
        Ecto.Changeset.change(generation, %{pages_total: 10, pages_completed: 10, status: :running})
        {:ok, _gen} = EveIndustrex.Repo.update(changeset)
        assert :ok == Orchestrator.finalize(strategy.id, 1, 5)

        strat = get_strategy_with_gens(strategy.id)
        gen = get_latest_gen(strat.generations)

        assert gen.status == :completed
        assert strat.status == :idle
    end

  end
end
