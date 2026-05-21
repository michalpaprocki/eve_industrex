defmodule EveIndustrex.Universe.MarketGroup.Import do
  alias EveIndustrex.Universe.MarketGroup.Mapper
  alias EveIndustrex.Universe.MarketGroup.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl

  def from_dump do
    jsonl = Jsonl.read_jsonl(Jsonl.get_market_groups_path)
    market_groups = Task.async_stream(jsonl, fn j -> Mapper.from_dump(j) end) |> Enum.map(fn {:ok, mg} -> mg end)
    Persistence.upsert_all(market_groups)
    Persistence.put_mg_assocs()
  end
end
