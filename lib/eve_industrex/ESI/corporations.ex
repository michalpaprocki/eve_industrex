defmodule EveIndustrex.ESI.Corporations do
  alias EveIndustrex.Corporation
  alias EveIndustrex.Utils
  @npc_corps_url "https://esi.evetech.net/latest/corporations/npccorps/"
  @corp_info_url "https://esi.evetech.net/latest/corporations/"
  @loyalty_offer_url "https://esi.evetech.net/latest/loyalty/stores/"
  def fetch_npc_corps() do
    npc_corps_ids = Utils.fetch_from_url(@npc_corps_url)
    Enum.map(npc_corps_ids, fn id -> {id, Utils.fetch_from_url(@corp_info_url<>Integer.to_string(id))} end)
  end
  def fetch_lp_offers() do
    npc_corps_ids = Corporation.get_npc_corps_ids()
    Enum.map(npc_corps_ids, fn id -> {id, Utils.fetch_from_url(@loyalty_offer_url<>Integer.to_string(id)<>"/offers/")} end)
  end
  def fetch_lp_top_offer() do
    id =  Enum.at(Corporation.get_npc_corps_ids(), 12)
    {id, Utils.fetch_from_url(@loyalty_offer_url<>Integer.to_string(id)<>"/offers/")}
  end
end
