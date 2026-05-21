defmodule EveIndustrex.Universe.System.Import do

  alias EveIndustrex.Universe.System.Mapper
  alias EveIndustrex.Infrastructure.Parsers.Jsonl
  alias EveIndustrex.Universe.System.Persistence

  def from_dump() do
    data = Jsonl.read_jsonl(Jsonl.get_systems_path)
    systems = Task.async_stream(data, fn d -> Mapper.from_dump(d) end) |> Enum.map(fn {:ok, s} -> s end)
    Persistence.upsert_all(systems)
  end
end
