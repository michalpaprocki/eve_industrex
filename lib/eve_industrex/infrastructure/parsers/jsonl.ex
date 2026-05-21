defmodule EveIndustrex.Infrastructure.Parsers.Jsonl do
  require Jason
  @blueprints_path "data_dump/blueprints.jsonl"
  @categories_path "data_dump/categories.jsonl"
  @constellations_path "data_dump/mapConstellations.jsonl"
  @groups_path "data_dump/groups.jsonl"
  @market_groups_path "data_dump/marketGroups.jsonl"
  @npc_corps_path "data_dump/npcCorporations.jsonl"
  @regions_path "data_dump/mapRegions.jsonl"
  @station_path "data_dump/npcStations.jsonl"
  @systems_path "data_dump/mapSolarSystems.jsonl"
  @type_materials_path "data_dump/typeMaterials.jsonl"
  @types_path "data_dump/types.jsonl"
  def get_bp_path, do: @blueprints_path
  def get_categories_path, do: @categories_path
  def get_groups_path, do: @groups_path
  def get_regions_path, do: @regions_path
  def get_constellations_path, do: @constellations_path
  def get_systems_path, do: @systems_path
  def get_stations_path, do: @station_path
  def get_market_groups_path, do: @market_groups_path
  def get_types_path, do: @types_path
  def get_type_materials_path, do: @type_materials_path
  def get_npc_corps_path, do: @npc_corps_path
  def read_jsonl(path) do
    {:ok, file} = File.read(path)
    objects = String.split(file, "\n", trim: true)
    Task.async_stream(objects, fn o -> Jason.decode!(o) end) |> Enum.map(fn {:ok, bp} -> bp end)
  end
end
