defmodule EveIndustrex.Universe.Group.Import do
  alias EveIndustrex.Universe.Group.Mapper
  alias EveIndustrex.Universe.Group.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl


  def from_dump do
    jsonl = Jsonl.read_jsonl(Jsonl.get_groups_path)
    groups = Task.async_stream(jsonl, fn j -> Mapper.from_dump(j) end) |> Enum.map(fn {:ok, group} -> group end)
    Persistence.upsert_all(groups)
  end
end
