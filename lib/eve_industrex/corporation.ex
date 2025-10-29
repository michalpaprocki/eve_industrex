defmodule EveIndustrex.Corporation do
  alias EveIndustrex.Logger.EiLogger
  alias EveIndustrex.Schemas.Type
  alias EveIndustrex.Schemas.CorpsOffers
  alias EveIndustrex.Schemas.LpReqItem
  alias EveIndustrex.Schemas.{LpOffer, NpcCorp}

  alias EveIndustrex.ESI.Corporations
  alias EveIndustrex.Repo
  import Ecto.Query
  def update_npc_corps_from_ESI() do
    case Corporations.fetch_npc_corps() do
      {:error, error} ->
        {:error, error}
      npc_corps ->
         Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps, fn {id, corp} ->
          case get_npc_corp(id) do
            nil ->
              %NpcCorp{corp_id: id}
            npc_corp ->
              npc_corp
          end
        |> NpcCorp.changeset(corp) |> Repo.insert_or_update() end)
        |> Stream.run()
    end
  end
  def update_npc_corps_from_ESI!() do
    npc_corps = Corporations.fetch_npc_corps!()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps, fn {id, corp} ->
          case get_npc_corp(id) do
            nil ->
              %NpcCorp{corp_id: id}
            npc_corp ->
              npc_corp
          end
        |> NpcCorp.changeset(corp) |> Repo.insert_or_update() end)
        |> Stream.run()
  end
  # rewrite the order and how are req_items inserted

  def update_npc_lp_offers_from_ESI() do
    if Repo.aggregate(Type, :count) == 0 do
      fun = Function.info(&update_npc_lp_offers_from_ESI/0)
      {:error,{:enoent, "Missing entities required: types", "#{Keyword.get(fun, :module)}"<>".#{Keyword.get(fun, :name)}"<>"/#{Keyword.get(fun, :arity)}"}}

    else

    npc_offers = Corporations.fetch_lp_offers!() |> Enum.filter(fn {_id, offers} -> offers != [] end)
    offers = Enum.map(npc_offers, fn {_id, o} -> o end) |> List.flatten() |> Enum.uniq()
    corps_offers = Enum.map(npc_offers, fn {cid, offer} -> {cid, Enum.map(offer, fn o -> o["offer_id"] end)} end)

    delete_req_items()

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

    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o -> Enum.map(o["required_items"], fn ri -> %LpReqItem{type_id: o["type_id"], offer_id: o["offer_id"]} |> LpReqItem.changeset(ri) |> Repo.insert() end) end) |> Stream.run()
    end
  end
def update_npc_lp_offers_from_ESI!() do
    if Repo.aggregate(Type, :count) == 0 do
      fun = Function.info(&update_npc_lp_offers_from_ESI!/0)
      EiLogger.log(:error,{:enoent, "Missing entities required: types", "#{Keyword.get(fun, :module)}"<>".#{Keyword.get(fun, :name)}"<>"/#{Keyword.get(fun, :arity)}"})
      raise "Missing entities required: types"

    else

      case Corporations.fetch_lp_offers() do
        {:error, error} ->
          {:error, error}
        {:ok, lp_offers} ->
          npc_offers = Enum.filter(lp_offers , fn {_id, offers} -> offers != [] end)
          offers = Enum.map(npc_offers, fn {_id, o} -> o end) |> List.flatten() |> Enum.uniq()
          corps_offers = Enum.map(npc_offers, fn {cid, offer} -> {cid, Enum.map(offer, fn o -> o["offer_id"] end)} end)



        delete_req_items()

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

        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o -> Enum.map(o["required_items"], fn ri -> %LpReqItem{type_id: o["type_id"], offer_id: o["offer_id"]} |> LpReqItem.changeset(ri) |> Repo.insert() end) end) |> Stream.run()
      end
    end
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
  def get_npc_corp(corp_id) when is_integer(corp_id), do: Repo.get_by(NpcCorp, corp_id: corp_id)
  def get_npc_corp(name) when is_binary(name), do: Repo.get_by(NpcCorp, name: name)
  def get_npc_corps_ids(), do: from(n in NpcCorp, select: n.corp_id) |> Repo.all()
  def get_npc_corps_offers() do
    from(c in NpcCorp, join: o in assoc(c, :offers)) |> Repo.all
  end
  def get_npc_offers_by_id(type_id), do: from(lp in LpOffer, where: lp.type_id == ^type_id, preload: :corps  ) |> Repo.all()

  def get_req_items(), do: Repo.all(LpReqItem)
  def get_lp_offers_with_reqs() do
    from(lp in LpOffer, preload: [:type, :req_items], left_join: r in LpReqItem, on: lp.offer_id == r.offer_id, preload: [req_items: r]) |> Repo.all
  end
  def get_corp_offers_type_ids(corp_id) do
    from(lp in LpOffer, join: c in assoc(lp, :corps), where: c.corp_id == ^corp_id, preload: [:req_items, :type, type: [:bp_products] ])|> Repo.all
  end
  def get_lp_offers(), do: Repo.all(LpOffer)
  def get_lp_offer(offer_id), do: Repo.get_by(LpOffer, offer_id: offer_id)
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
  def get_corp_lp_offers(corp_id, limit, offset) do
      from(lp in LpOffer, join: c in assoc(lp, :corps),
      where: c.corp_id == ^corp_id,
      left_join: r in LpReqItem, on: c.corp_id == r.offer_id,
      inner_join: t in assoc(lp, :type),
      order_by: t.name,
      limit: ^limit,
      offset: ^offset,
       preload: [:req_items, :type, type: [:products, :bp_products, products: [:material_type]], req_items: [:type]]
     ) |> Repo.all
  end
  def get_corp_lp_offers2(corp_id) do
    from(lp in LpOffer, join: c in assoc(lp, :corps),
     where: c.corp_id == ^corp_id, preload: [:type], left_join: r in LpReqItem, on: lp.offer_id == r.offer_id, preload: [req_items: r]) |> Repo.all()
  end
end
