defmodule EveIndustrex.LoyaltyPoints.NpcCorp.Import do
  alias EveIndustrex.LoyaltyPoints.NpcCorp.Mapper
  alias EveIndustrex.LoyaltyPoints.NpcCorp.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl

  def from_dump() do
    jsonl = Jsonl.read_jsonl(Jsonl.get_npc_corps_path)
    corps = Task.async_stream(jsonl, fn j -> Mapper.from_dump(j) end) |> Enum.map(fn {:ok, c} -> c end)
    Persistence.upsert_all(corps)
  end
end
