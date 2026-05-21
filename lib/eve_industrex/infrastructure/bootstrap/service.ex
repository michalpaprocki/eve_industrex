defmodule EveIndustrex.Infrastructure.Bootstrap.Service do


  alias EveIndustrex.Schemas.TqVersion
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
  def populate_cache do
    Loader.Region.init()
    Loader.Constellation.init()
    Loader.System.init()
    Loader.Station.init()
    Loader.Category.init()
    Loader.Group.init()
    Loader.MarketGroup.init()
  end
end
