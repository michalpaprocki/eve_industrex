defmodule EveIndustrex.Universe.Constellation.Import do
  alias EveIndustrex.Universe.Constellation.Mapper
  alias EveIndustrex.Universe.Constellation.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl
  def from_dump() do
    data = Jsonl.read_jsonl(Jsonl.get_constellations_path)
    constellations = Task.async_stream(data, fn d ->
      Mapper.from_dump(d)
    end) |> Enum.map(fn {:ok, constellation} -> constellation end)
    Persistence.upsert_all(constellations)
  end
end
