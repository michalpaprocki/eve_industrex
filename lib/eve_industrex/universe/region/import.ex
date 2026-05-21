defmodule EveIndustrex.Universe.Region.Import do
  alias EveIndustrex.Universe.Region.Mapper
  alias EveIndustrex.Infrastructure.Parsers.Jsonl
  alias EveIndustrex.Universe.Region.Persistence

  def from_dump() do
    jsonl = Jsonl.read_jsonl(Jsonl.get_regions_path)
    regions = Task.async_stream(jsonl, fn j -> Mapper.from_dump(j) end) |> Enum.map(fn {:ok, region} -> region end)
    Persistence.upsert_all(regions)
  end
end
