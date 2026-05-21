defmodule EveIndustrex.Universe.Category.Import do

  alias EveIndustrex.Universe.Category.Mapper
  alias EveIndustrex.Universe.Category.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl


  def from_dump do
    jsonl = Jsonl.read_jsonl(Jsonl.get_categories_path)
    categories = Task.async_stream(jsonl, fn j -> Mapper.from_dump(j) end) |> Enum.map(fn {:ok, category} -> category end)
    Persistence.upsert_all(categories)
  end
end
