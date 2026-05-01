defmodule EveIndustrex.Parsers.Jsonl do
  require Jason
  @blueprints_path "data_dump/blueprints.jsonl"
  @type_materials_path "data_dump/typeMaterials.yaml"
  @types_path "data_dump/types.yaml"
  @categories_path "data_dump/categories.yaml"
  @groups_path "data_dump/groups.yaml"
  @market_groups_path "data_dump/marketGroups.yaml"

  def read_jsonl(path) do
    {:ok, file} = File.read(path)
    objects = String.split(file, "\n", trim: true)
    Task.async_stream(objects, fn o -> Jason.decode!(o) end) |> Enum.to_list()
  end
end
