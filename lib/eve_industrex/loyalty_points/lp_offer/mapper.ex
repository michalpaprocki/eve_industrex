defmodule EveIndustrex.LoyaltyPoints.LpOffer.Mapper do

  def from_esi(data) do
    %{
      :isk_cost => Map.get(data, "isk_cost"),
      :lp_cost => Map.get(data, "lp_cost"),
      :quantity => Map.get(data, "quantity"),
      :type_id => Map.get(data, "type_id"),
      :offer_id => Map.get(data, "offer_id"),

    }
  end
  def dump_to_ids(npc_corps_data) do
    Enum.map(npc_corps_data, fn npd ->
      Map.get(npd, "_key", nil)
    end)
  end

  def filter_out_empty(list_of_offers), do: Enum.filter(list_of_offers, fn {_id, offers} -> offers != [] end)
  def flatten_and_get_unique_offers(non_empty_offers), do: Enum.map(non_empty_offers, fn {_id, o} -> o end) |> List.flatten() |> Enum.uniq()
  def map_corp_and_offers_ids(non_empty_offers), do: Enum.map(non_empty_offers, fn {cid, offer} -> {cid, Enum.map(offer, fn o -> o["offer_id"] end)} end)

end
