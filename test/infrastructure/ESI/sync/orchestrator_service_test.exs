defmodule Infrastructure.ESI.Sync.OrchestratorServiceTest do
  use EveIndustrex.DataCase
  use ExUnit.Case
  alias EveIndustrex.Infrastructure.ESI.Headers
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Infrastructure.ESI.Response
  alias EveIndustrex.Infrastructure.ESI.Sync.OrchestratorService
  import EveIndustrex.Test.EsiFixtures

  describe "calc_delay/1" do

    test "uses exponential backoff" do
      assert 15 == OrchestratorService.calc_delay(0)
      assert 30 == OrchestratorService.calc_delay(1)
      assert 60 == OrchestratorService.calc_delay(2)
    end

    test "caps at 1800 seconds" do
      assert 1800 == OrchestratorService.calc_delay(20)
    end
  end
  describe "orchestrate/7" do
    # to do verify special page 1 behaviour , route group etags etc
    setup  do
      resource_type = resource_type_fixture()
      strategy = strategy_fixture(resource_type.id)
      generation = generation_fixture(strategy.id)
      {:ok, %{resource_type: resource_type, strategy: strategy, generation: generation}}
    end
    test "1 page resource on successful sync returns :ok, amount of pages and gen id", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert {:ok, 1, generation.id} == OrchestratorService.orchestrate(fetch_fn(esi_response(200, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)
      assert gen.pages_completed == 1
      assert gen.pages_total == 1
      assert gen_page.status == :completed

    end
    test "multi page resource on successful sync returns :fanout and amount of pages on completion of 1st page", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert {:fanout, 20} == OrchestratorService.orchestrate(fetch_fn(esi_response(200, [], "20")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)
      assert gen.pages_completed == 1
      assert gen.pages_total == 20
      assert gen_page.status == :completed

    end
    test "multi page resource on successful sync returns :ok on completion of subsequent pages", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert :ok == OrchestratorService.orchestrate(fetch_fn(esi_response(200, [], "20")), generation.id, strategy.next_generation, 0, strategy, metadata(), 2)
      {gen, gen_page} = get_generation(generation.id, 2)
      assert gen.pages_total == 20
      assert gen_page.status == :completed

    end
    test "after being rate limited on 1st attempt, returns :snooze, delay", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert {:snooze, 15} == OrchestratorService.orchestrate(fetch_fn(esi_response(429, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)

       assert gen.pages_completed == 0
       assert gen_page.status == :rate_limited

    end
    test "resource returns :ok when etag did not expire, generation is completed", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert :ok == OrchestratorService.orchestrate(fetch_fn(esi_response(304, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)
       assert gen.pages_total == 1
       assert gen.pages_completed == 1
       assert gen.last_error == "not_modified"
       assert gen.status == :completed
       assert gen_page.status == :matched
    end
    test "when receiving 500 status codes, emits snooze, delay", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert {:snooze, 15} == OrchestratorService.orchestrate(fetch_fn(esi_response(500, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)
       assert gen.pages_total == nil
       assert gen.pages_completed == 0
       assert gen.status == :running
       assert gen_page.status == :retryable
       assert gen_page.attempts == 0
       assert gen_page.last_error == "500"

    end
    test "when receiving 404 status code marks generation as :critical", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert :ok == OrchestratorService.orchestrate(fetch_fn(esi_response(404, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)

       assert gen.pages_total == nil
       assert gen.pages_completed == 0
       assert gen.status == :critical
       assert gen.last_error == "not found"
       assert gen_page.last_error == "404"

    end
    test "other 400 status codes marks generation as :critical", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert :ok == OrchestratorService.orchestrate(fetch_fn(esi_response(401, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)
       assert gen.pages_total == nil
       assert gen.pages_completed == 0
       assert gen.status == :critical
       assert gen.last_error == "client error"
       assert gen_page.last_error == "401"

    end
    test "other 300 status codes marks generation as :critical", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert :ok == OrchestratorService.orchestrate(fetch_fn(esi_response(300, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata(), 1)
      {gen, gen_page} = get_generation(generation.id, 1)
       assert gen.pages_total == nil
       assert gen.pages_completed == 0
       assert gen.status == :critical
       assert gen.last_error == "unexpected_response"
       assert gen_page.last_error == "300"

    end
    test "unknown status codes marks generation as :critical", %{resource_type: resource_type, strategy: strategy, generation: generation} do

      assert :ok == OrchestratorService.orchestrate(fetch_fn(esi_response(100, [], "1")), generation.id, strategy.next_generation, 0, strategy, metadata() , 1)
      {gen, gen_page} = get_generation(generation.id, 1)
       assert gen.pages_total == nil
       assert gen.pages_completed == 0
       assert gen.status == :critical
       assert gen.last_error == "invalid_status"
       assert gen_page.last_error == "100"

    end
  end



  defp esi_response(status, body \\ [], pages \\ "1") do
    {:ok, %Response{
      status: status,
      body: body,
      headers: %Headers{
        pages: pages,
        rate_limit_group: "market_orders",
        rate_limit_remaining: "10000",
        rate_limit: "120000/15m",
        retry_after: 30
      }
    }}
  end

  defp fetch_fn(response) do
    fn _, _, _ -> response end
  end
  defp get_generation(gen_id, gen_page) do
    gen = Sync.Query.get_generation(gen_id) |> EveIndustrex.Repo.preload(:generation_pages)
    gen_page = Enum.find(gen.generation_pages, fn p -> p.page_number == gen_page end)
    {gen, gen_page}
  end
  defp metadata() do
    %{etag: "random_string", expires_at: DateTime.utc_now()}
  end
end
