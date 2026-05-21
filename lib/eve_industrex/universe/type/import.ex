defmodule EveIndustrex.Universe.Type.Import do
  alias EveIndustrex.Universe.Type.Mapper
  alias EveIndustrex.Universe.Type.Sync
  alias EveIndustrex.Universe.Type.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl

  def from_dump() do
    jsonl = Jsonl.read_jsonl(Jsonl.get_types_path)
    types = Task.async_stream(jsonl, fn j -> Mapper.from_dump(j) end) |> Enum.map(fn {:ok, s} -> s end) |> Enum.chunk_every(1000)
    Enum.map(types, fn t -> Persistence.upsert_all(t) end)
  end
  def type_from_ESI(type_id) do
    type = Sync.fetch_type_from_ESI!(type_id)
    Persistence.upsert(type)
  end
end
