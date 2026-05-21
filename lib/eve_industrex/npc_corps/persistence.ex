defmodule EveIndustrex.NpcCorps.Persistence do
  alias EveIndustrex.LoyaltyPoints.{LpReqItem, NpcCorp, LpOffer, CorpsOffers}
  alias EveIndustrex.Repo
  import Ecto.Query
  def get_npc_corp(id) do
    Repo.get_by(NpcCorp, corp_id: id)
  end
  def get_npc_corps(), do: Repo.all(NpcCorp)
  def save_npc_corp(npc_corp) do
    Repo.insert(npc_corp)
  end
  def save_npc_corps(list_of_npc_corps) do
    Repo.insert_all(NpcCorp, list_of_npc_corps)
  end

  def upsert_npc_corps(list_of_npc_corps) when is_list(list_of_npc_corps) do
    Task.async_stream(list_of_npc_corps, fn nc ->
      upsert_npc_corp(nc)
    end) |> Stream.run
  end

  def upsert_npc_corp(npc_corp) do
    case get_npc_corp(Map.get(npc_corp, "_key")) do
        nil ->
          %NpcCorp{}
        npc_corp ->
          npc_corp
      end
      |> NpcCorp.changeset(%{
          corp_id: Map.get(npc_corp, "_key"),
          name: Map.get(npc_corp, "name"),
          description: Map.get(npc_corp, "description")
        })
      |> Repo.insert_or_update()
  end

  def get_lp_offer(id) do
    Repo.get_by(LpOffer, offer_id: id)
  end


  def upsert_lp_offers(list_of_offers) when is_list(list_of_offers) do


    npc_offers = Enum.filter(list_of_offers, fn {_id, offers} -> offers != [] end)

    offers = Enum.map(npc_offers, fn {_id, o} -> o end) |> List.flatten() |> Enum.uniq()
    corps_offers = Enum.map(npc_offers, fn {cid, offer} -> {cid, Enum.map(offer, fn o -> o["offer_id"] end)} end)

    # delete_req_items()


    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o ->
      case get_lp_offer(o["offer_id"]) do
        nil ->
          %LpOffer{}
        lp_offer ->
          lp_offer
      end
    |> LpOffer.changeset(o)
    |> Repo.insert_or_update() end) |> Stream.run()

    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, corps_offers, fn {cid, offer_ids} -> Repo.get_by(NpcCorp, corp_id: cid) |> Repo.preload([:offers]) |> Ecto.Changeset.change() |> Ecto.Changeset.put_assoc(:offers, Enum.map(offer_ids, fn id -> Repo.get_by(LpOffer, offer_id: id) end))  |> Repo.update() end) |> Stream.run()
    ri_type_ids = Enum.map(offers, fn  o -> Enum.map(o["required_items"], fn  ri-> ri["type_id"] end) end)
    offers_type_ids = Enum.map(offers, fn o -> o["type_id"] end)


    type_ids = ri_type_ids ++ offers_type_ids |> Enum.uniq() |> List.flatten

    missing_types = Enum.map(type_ids, fn  t -> {t, EveIndustrex.Universe.Type.Persistence.get_type(t)} end) |> Enum.filter(fn x -> elem(x, 1) == nil end)

    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, missing_types, fn {type_id, _} -> EveIndustrex.Universe.Type.Import.update_type_from_ESI(type_id) end) |> Stream.run()
    # change this to upsert
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o -> Enum.map(o["required_items"], fn ri -> %LpReqItem{type_id: o["type_id"], offer_id: o["offer_id"]} |> LpReqItem.changeset(ri) |> Repo.insert() end) end) |> Stream.run()
  end
  def get_npc_corps_names_and_ids() do
    from(c in NpcCorp, as: :corp, where: exists(
      from(co in CorpsOffers, where: parent_as(:corp).corp_id == co.corp_id and not is_nil(co.offer_id))
    ), order_by: [asc: c.name], select: [:name, :id, :corp_id]) |> Repo.all
  end
  def get_corp_lp_offers_count(corp_id), do: Repo.aggregate(from(lp in LpOffer, join: c in assoc(lp, :corps), where: c.corp_id == ^corp_id), :count)
  def get_corp_lp_offers(corp_id) do
      from(lp in LpOffer, join: c in assoc(lp, :corps),
      where: c.corp_id == ^corp_id,
      left_join: r in LpReqItem, on: c.corp_id == r.offer_id,
      left_join: t in assoc(lp, :type),
      order_by: t.name,
       preload: [:req_items, :type, type: [:products, :bp_products, :group, bp_products: [:group], products: [:material_type, material_type: [:group, group: [:category]]]], req_items: [:type, type: [:group]]]
     ) |> Repo.all
  end
end
