defmodule EveIndustrex.ESI.Universe do
  alias EveIndustrex.Utils
  @regions_url "https://esi.evetech.net/latest/universe/regions/"
  @constellations_url "https://esi.evetech.net/latest/universe/constellations/"
  @systems_url "https://esi.evetech.net/latest/universe/systems/"
  @stations_url "https://esi.evetech.net/latest/universe/stations/"
  @categories_url "https://esi.evetech.net/latest/universe/categories/"
  @groups_url "https://esi.evetech.net/latest/universe/groups/"
  def fetch_regions() do
    regions_ids = Utils.fetch_from_url(@regions_url)
    Enum.map(regions_ids, fn ri ->Utils.fetch_from_url(@regions_url<>~s"#{ri}") end)
  end

  def fetch_constellations() do
    constellations_ids = Utils.fetch_from_url(@constellations_url)
    Enum.map(constellations_ids, fn ci ->Utils.fetch_from_url(@constellations_url<>~s"#{ci}") end)
  end

  def fetch_systems() do
    systems_ids = Utils.fetch_from_url(@systems_url)
    Enum.map(systems_ids, fn si ->Utils.fetch_from_url(@systems_url<>~s"#{si}") end)
  end

  def fetch_station(id) do
    Utils.fetch_from_url(@stations_url<>~s"#{id}")
  end
  def fetch_categories() do
    categories_ids = Utils.fetch_from_url(@categories_url)
    Enum.map(categories_ids, fn ci -> Utils.fetch_from_url(@categories_url<>~s"#{ci}") end)
  end
  def fetch_groups() do
    current_pages = Utils.get_ESI_pages_amount(@groups_url)
    groups = Utils.fetch_ESI_pages(@groups_url, String.to_integer(current_pages))
    Enum.map(Enum.with_index(groups),fn {g, i} -> Utils.fetch_from_url(@groups_url<>~s"#{g}", i) end)
  end
  def fetch_group(group_id) do
    Utils.fetch_from_url(@groups_url<>~s"#{group_id}")
  end

end
