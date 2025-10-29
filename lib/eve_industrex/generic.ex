defmodule EveIndustrex.Generic do
  alias EveIndustrex.Schemas.TqVersion
  alias EveIndustrex.Repo
  alias EveIndustrex.{Blueprints, Corporation, Materials, Types, Universe, Repo}
  alias EveIndustrex.Schemas.{Region, Constellation, System, Station, Category, Group, MarketGroup,Type, Material, NpcCorp, LpOffer, Blueprint}
  @used_schemas [Region, Constellation, System, Station, Category, Group, MarketGroup,Type, Material, NpcCorp, LpOffer, Blueprint]
  def get_tq_version() do
    Repo.one(TqVersion)
  end
  def upsert_tq_version(string) do
    case Repo.one(TqVersion) do
      nil ->
        %TqVersion{}
      version ->
        version
    end
    |> TqVersion.changeset(%{:version => string})
    |> Repo.insert_or_update()
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
  def populate_db(Category), do: Universe.update_categories_from_dump()
  def populate_db(Group), do: Universe.update_groups_from_dump()
  def populate_db(Region), do: Universe.update_regions_from_ESI!()
  def populate_db(Constellation), do: Universe.update_constellations_from_ESI!()
  def populate_db(System), do: Universe.update_systems_from_ESI!()
  def populate_db(Station), do: Universe.update_stations_from_ESI!()
  def populate_db(MarketGroup), do: Types.update_market_groups_from_dump()
  def populate_db(Type), do: Types.update_types_from_dump_with_time_tc()
  def populate_db(Material), do: Materials.insert_materials_from_dump()
  def populate_db(NpcCorp), do: Corporation.update_npc_corps_from_ESI!()
  def populate_db(LpOffer), do: Corporation.update_npc_lp_offers_from_ESI!()
  def populate_db(Blueprint), do: Blueprints.insert_bps_from_dump()
end
