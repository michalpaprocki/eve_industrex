defmodule EveIndustrex.Infrastructure.Bootstrap.Service do
require Logger

  alias EveIndustrex.Infrastructure.ESI.Sync.Persistence
  alias EveIndustrex.Infrastructure.ESI.Sync.SyncProvider
  alias EveIndustrex.Infrastructure.ESI
  alias EveIndustrex.Schemas.TqVersion
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.{Region, Constellation, System, Station, Category, Group, MarketGroup, Type}
  alias EveIndustrex.Industry.{Blueprint, ReprocessMaterial}
  alias EveIndustrex.LoyaltyPoints.{NpcCorp, LpOffer}
  alias EveIndustrex.Infrastructure.Cache.Loader
  @used_schemas [Region, Constellation, System, Station, Category, Group, MarketGroup, Type, NpcCorp, LpOffer, Blueprint, ReprocessMaterial]
  def get_tq_version() do
    Repo.one(TqVersion)
  end

  def get_present_records() do
    counts = Enum.map(@used_schemas, fn s -> {s, Repo.aggregate(s, :count)} end)
    if Enum.any?(counts, fn {_schema, count} -> count == 0 end) do
      {false, Enum.filter(counts, fn {_schema, count} -> count == 0 end)}
    else
      {true}
    end
  end
  def get_used_schemas(), do: @used_schemas
  def populate_db(Category), do: Category.Import.from_dump()
  def populate_db(Group), do: Group.Import.from_dump()
  def populate_db(Region), do: Region.Import.from_dump()
  def populate_db(Constellation), do: Constellation.Import.from_dump()
  def populate_db(System), do: System.Import.from_dump()
  def populate_db(Station), do: Station.Import.from_esi()
  def populate_db(MarketGroup), do: MarketGroup.Import.from_dump()
  def populate_db(Type), do: Type.Import.from_dump()
  def populate_db(ReprocessMaterial), do: ReprocessMaterial.Import.from_dump()
  def populate_db(NpcCorp), do: NpcCorp.Import.from_dump()
  def populate_db(LpOffer), do: LpOffer.Import.from_esi()
  def populate_db(Blueprint), do: Blueprint.Import.from_dump()
  def populate_cache() do
    Loader.Region.init()
    Loader.Constellation.init()
    Loader.System.init()
    Loader.Station.init()
    Loader.Category.init()
    Loader.Group.init()
    Loader.MarketGroup.init()
    Loader.Type.init()
    Loader.NpcCorp.init()
    Loader.LpOffers.init()
    Loader.CorpOffers.init()
    Loader.Blueprint.init()
  end
  def resources_missing?(), do: if(Sync.Query.get_resource_types_count() > 0, do: false, else: true)
  def get_resources_with_missing_strategies() do
    resource_types = Sync.Query.get_resource_types()
    Enum.map(resource_types, fn r ->
      if r.strategies_count == 0 || r.strategies_count == nil do
        {false, r}
      else
        {true, nil}
      end
    end)
    |> Enum.filter(fn {boolean, _r} ->
      boolean == false
    end)
    |> Enum.map(fn {_boolean, r} -> r end)
  end
  def put_resources() do
    Sync.Query.get_initial_resources()
    |> Enum.map(fn r -> Sync.Mapper.to_resource_type(r) end)
    |> Sync.Persistence.insert_all_resource_types()
  end
  def maybe_allocate_strategies do
    get_resources_with_missing_strategies()
    |> allocate_strategies()
    |> read_out_strats_count()
  end
  def allocate_strategies(resource_types) do

    # resource_types = Sync.Query.get_resource_types()
    Enum.map(resource_types, fn r ->
      targets = get_targets(r.name)

      Sync.Persistence.update_resource_type_strategies_count(r.id, %{strategies_count: targets.count})

      Enum.map(targets.ids, fn id ->
        SyncProvider.default_market_order_strategy(id, r.id)
      end)
    end)
    |> List.flatten()
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk ->
      Sync.Persistence.upsert_strategies(chunk)
    end)
    resource_types
  end
  def read_out_strats_count(resource_types) do
    Enum.map(resource_types, fn r ->
      count = Sync.Query.aggregate_strats_count(r.id)
      Logger.info(Integer.to_string(count)<>" strategies inserted for #{inspect(r.name)}.")
    end)
  end
  defp get_targets(resource_name) do
    case resource_name do
      "market_orders" ->
        targets = Region.Store.get_ids()
       %{
          ids: targets,
          count: length(targets)
        }

      _ ->
        []
    end
  end

end
