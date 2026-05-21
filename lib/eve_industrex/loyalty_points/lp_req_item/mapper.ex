defmodule EveIndustrex.LoyaltyPoints.LpReqItem.Mapper do

  def get_offer_type_ids(offers) do
    ri_type_ids = type_ids_from_req_items(offers)
    offers_type_ids = Enum.map(offers, fn o -> o["type_id"] end)
    ri_type_ids ++ offers_type_ids |> Enum.uniq() |> List.flatten
  end
  def get_req_items(offers) do
    Enum.map(offers, fn o -> Enum.map(o["required_items"], fn ri ->

    %{
      :quantity=> Map.get(ri, "quantity"),
      :offer_id => Map.get(o, "offer_id"),
      :type_id => Map.get(ri, "type_id")
    }
  end) end)
  end

  defp type_ids_from_req_items(offers) do
    Enum.map(offers, fn  o -> Enum.map(o["required_items"], fn  ri-> ri["type_id"] end) end)
  end

  # def upsert_lp_offers(list_of_offers) when is_list(list_of_offers) do

  #   npc_offers = Enum.filter(list_of_offers, fn {_id, offers} -> offers != [] end)

  #   offers = Enum.map(npc_offers, fn {_id, o} -> o end) |> List.flatten() |> Enum.uniq()
  #   corps_offers = Enum.map(npc_offers, fn {cid, offer} -> {cid, Enum.map(offer, fn o -> o["offer_id"] end)} end)

  #   # delete_req_items()


  #   Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o ->
  #     case get_lp_offer(o["offer_id"]) do
  #       nil ->
  #         %LpOffer{}
  #       lp_offer ->
  #         lp_offer
  #     end
  #   |> LpOffer.changeset(o)
  #   |> Repo.insert_or_update() end) |> Stream.run()

  #   Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, corps_offers, fn {cid, offer_ids} -> Repo.get_by(NpcCorp, corp_id: cid) |> Repo.preload([:offers]) |> Ecto.Changeset.change() |> Ecto.Changeset.put_assoc(:offers, Enum.map(offer_ids, fn id -> Repo.get_by(LpOffer, offer_id: id) end))  |> Repo.update() end) |> Stream.run()

  #   ri_type_ids = Enum.map(offers, fn  o -> Enum.map(o["required_items"], fn  ri-> ri["type_id"] end) end)
  #   offers_type_ids = Enum.map(offers, fn o -> o["type_id"] end)


  #   type_ids = ri_type_ids ++ offers_type_ids |> Enum.uniq() |> List.flatten

  #   missing_types = Enum.map(type_ids, fn  t -> {t, EveIndustrex.Universe.Type.Persistence.get_type(t)} end) |> Enum.filter(fn x -> elem(x, 1) == nil end)

  #   Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, missing_types, fn {type_id, _} -> EveIndustrex.Universe.Type.Import.update_type_from_ESI(type_id) end) |> Stream.run()
  #   # change this to upsert
  #   Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, offers, fn o -> Enum.map(o["required_items"], fn ri -> %LpReqItem{type_id: o["type_id"], offer_id: o["offer_id"]} |> LpReqItem.changeset(ri) |> Repo.insert() end) end) |> Stream.run()
  # end
end
