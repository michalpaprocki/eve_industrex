defmodule EveIndustrex.LoyaltyPoints.LpOffer.Sync do
  alias EveIndustrex.Utils
  @loyalty_offer_url "https://esi.evetech.net/latest/loyalty/stores/"
  def from_esi_with_ids(npc_corps_ids) do
     Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps_ids, fn id ->
     {id, Utils.fetch_from_url!(@loyalty_offer_url<>Integer.to_string(id)<>"/offers")}
    end) |>  Enum.map(fn {:ok, {id, offer}} -> {id, offer} end)
  end
end
