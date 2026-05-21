defmodule EveIndustrex.LoyaltyPoints.LpOffer.Import do
  alias EveIndustrex.LoyaltyPoints.LpOffer.Persistence
  alias EveIndustrex.LoyaltyPoints.LpOffer.Sync
  alias EveIndustrex.Infrastructure.Parsers.Jsonl
  alias EveIndustrex.LoyaltyPoints.LpOffer.Mapper

  def from_esi() do
    data = Jsonl.read_jsonl(Jsonl.get_npc_corps_path)

    npc_corps_ids =  Mapper.dump_to_ids(data) |> Enum.filter(fn x -> x != nil end)

    fetched_offers = Sync.from_esi_with_ids(npc_corps_ids)
    offers = Mapper.filter_out_empty(fetched_offers) |> Mapper.flatten_and_get_unique_offers()

    Persistence.upsert_all(Enum.map(offers, fn o -> Mapper.from_esi(o) end))
    EveIndustrex.LoyaltyPoints.CorpOffer.Persistence.upsert_all(Mapper.map_corp_and_offers_ids(fetched_offers) |> Enum.chunk_every(1000))

    type_ids = EveIndustrex.LoyaltyPoints.LpReqItem.Mapper.get_offer_type_ids(offers) |> Enum.uniq() |> Enum.sort(:asc)
    present_types = EveIndustrex.Universe.Type.Query.get_types_ids(type_ids)

    missing_type_ids = for {t, i} <- Enum.with_index(type_ids) do
      {t, Enum.at(present_types, i, :empty)}
    end |> Enum.filter(fn {_t1, t2} -> t2 == nil end)
    fetched_type_ids = EveIndustrex.Universe.Type.Sync.fetch_types_from_ESI!(missing_type_ids)

    EveIndustrex.Universe.Type.Persistence.upsert_all(Enum.map(fetched_type_ids, fn t -> EveIndustrex.Universe.Type.Mapper.from_esi(t) end))
    req_items = EveIndustrex.LoyaltyPoints.LpReqItem.Mapper.get_req_items(offers) |> List.flatten()
    EveIndustrex.LoyaltyPoints.LpReqItem.Persistence.delete_all()
    EveIndustrex.LoyaltyPoints.LpReqItem.Persistence.insert_all(req_items)
  end
end
