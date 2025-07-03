defmodule EveIndustrex.ESI.Universe do
  alias EveIndustrex.Utils
  @regions_url "https://esi.evetech.net/latest/universe/regions/"
  @constellations_url "https://esi.evetech.net/latest/universe/constellations/"
  @systems_url "https://esi.evetech.net/latest/universe/systems/"
  @stations_url "https://esi.evetech.net/latest/universe/stations/"


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

end
