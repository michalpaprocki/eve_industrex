defmodule EveIndustrex.Test.EsiFixtures do
  alias EveIndustrex.Infrastructure.ESI.{Headers, Response}
  alias EveIndustrex.Infrastructure.ESI.Sync

  def resource_type_fixture(name \\ "test_resource") do
    %Sync.ResourceType{}
    |> Sync.ResourceType.changeset(%{name: name})
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
  def get_strategy_with_gens(strategy_id) do
    Sync.Query.get_strategy_with_generation(strategy_id)
  end
  def get_latest_gen(generations) do
    Enum.find(generations, fn g -> g.generation == 1 end)
  end
  def fetch_fn(response) do
    fn _, _, _ -> response end
  end
  def get_generation(gen_id, gen_page) do
    gen = Sync.Query.get_generation(gen_id) |> EveIndustrex.Repo.preload(:generation_pages)
    gen_page = Enum.find(gen.generation_pages, fn p -> p.page_number == gen_page end)
    {gen, gen_page}
  end
  def metadata(etag \\ nil, expires_at \\ nil, last_modified \\ DateTimeParser.parse_datetime!("Fri, 19 Jun 2026 07:31:36 GMT", to_utc: true)|> DateTime.from_naive!("Etc/UTC")|>DateTime.truncate(:second)) do
    %{etag: etag, expires_at: expires_at, last_modified: last_modified}
  end
  def esi_response(status, body \\ [], pages \\ "1", etag \\ "random_string", rate_limit_group \\ "market_orders", last_modified \\ "Fri, 19 Jun 2026 07:31:36 GMT") do
    {:ok, %Response{
      status: status,
      body: body,
      headers: %Headers{
        pages: pages,
        rate_limit_group: rate_limit_group,
        rate_limit_remaining: "10000",
        rate_limit: "120000/15m",
        retry_after: 30,
        etag: etag,
        expires_at: "Fri, 19 Jun 2026 07:36:36 GMT",
        last_modified: last_modified
      }
    }}
  end
  def update_strategy(strategy) do
    Sync.Persistence.update_strategy(strategy)
  end

end
