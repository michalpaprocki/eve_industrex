defmodule EveIndustrex.Corporation do
  alias EveIndustrex.Schemas.CorpsOffers
  alias EveIndustrex.Schemas.LpReqItem
  alias EveIndustrex.Schemas.{LpOffer, NpcCorp}

  alias EveIndustrex.ESI.Corporations
  alias EveIndustrex.Repo
  import Ecto.Query
  def update_npc_corps() do
    npc_corps = Corporations.fetch_npc_corps()
    delete_npc_corps()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps, fn {id, corp} -> %NpcCorp{corp_id: id} |> NpcCorp.changeset(corp) |> Repo.insert() end)
    |> Stream.run()
  end

  # rewrite the order and how are req_items inserted

  def update_npc_lp_offers() do
    npc_offers = Corporations.fetch_lp_offers() |> Enum.filter(fn {_id, offers} -> offers != [] end)
    offers = Enum.map(npc_offers, fn {_id, o} -> o end) |> List.flatten() |> Enum.uniq()
    corps_offers = Enum.map(npc_offers, fn {cid, offer} -> {cid, Enum.map(offer, fn o -> o["offer_id"] end)} end)

    delete_req_items()
    delete_npc_lp_offers()

    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o -> %LpOffer{type_id: o["type_id"]} |> LpOffer.changeset(o) |> Repo.insert() end) |> Stream.run()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, corps_offers, fn {cid, offer_ids} -> Repo.get_by(NpcCorp, corp_id: cid) |> Repo.preload([:offers]) |> Ecto.Changeset.change() |> Ecto.Changeset.put_assoc(:offers, Enum.map(offer_ids, fn id -> Repo.get_by(LpOffer, offer_id: id) end))  |> Repo.update() end) |> Stream.run()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o -> Enum.map(o["required_items"], fn ri -> %LpReqItem{type_id: o["type_id"], offer_id: o["offer_id"]} |> LpReqItem.changeset(ri) |> Repo.insert() end) end) |> Stream.run()


  end

  def delete_npc_corps(), do: Repo.delete_all(NpcCorp)
  def delete_npc_lp_offers(), do: Repo.delete_all(from(co in "corps_offers"))
  def delete_req_items(), do: Repo.delete_all(LpReqItem)
  def get_npc_corps(), do: Repo.all(NpcCorp)

  def get_npc_corps_names_and_ids() do
    from(c in NpcCorp, as: :corp, where: exists(
      from(co in CorpsOffers, where: parent_as(:corp).corp_id == co.corp_id and not is_nil(co.offer_id))
    ), order_by: [asc: c.name]) |> Repo.all
  end
  def get_npc_corps_ids(), do: from(n in NpcCorp, select: n.corp_id) |> Repo.all()
  def get_npc_corps_offers() do
    from(c in NpcCorp, join: o in assoc(c, :offers)) |> Repo.all
  end
  def get_npc_offers_by_id(id), do: Repo.get_by(LpOffer, offer_id: id)
  @spec get_req_items() :: any()
  def get_req_items(), do: Repo.all(LpReqItem)
  def get_lp_offers_with_reqs() do
    from(lp in LpOffer, preload: [:type, :req_items], left_join: r in LpReqItem, on: lp.offer_id == r.offer_id, preload: [req_items: r]) |> Repo.all
  end
  def get_corp_lp_offers(corp_id) do

    from(lp in LpOffer, join: c in assoc(lp, :corps), where: c.corp_id == ^corp_id, preload: [:req_items, :type], join: r in LpReqItem, on: lp.offer_id == r.offer_id, preload: [req_items: :type, req_items: r]) |> Repo.all


  end
end
