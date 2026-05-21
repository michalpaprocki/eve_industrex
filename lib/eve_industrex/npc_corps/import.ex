defmodule EveIndustrex.NpcCorps.Import do
  alias EveIndustrex.NpcCorps.Persistence
  alias EveIndustrex.Infrastructure.Parsers.Jsonl
  def update_npc_corps_from_dump() do
    corps = Jsonl.read_jsonl(Jsonl.get_npc_corps_path)
    Persistence.upsert_npc_corps(corps)
  end
  def update_lp_offers_from_ESI() do
    offers = EveIndustrex.NpcCorps.Sync.fetch_lp_offers_from_ESI!()
    Persistence.upsert_lp_offers(offers)
  end
end
