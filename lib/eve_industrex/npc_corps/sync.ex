defmodule EveIndustrex.NpcCorps.Sync do
  alias EveIndustrex.Utils
  alias EveIndustrex.Infrastructure.Parsers.Jsonl
  @loyalty_offer_url "https://esi.evetech.net/latest/loyalty/stores/"

  def fetch_lp_offers_from_ESI!() do
    npc_corps = Jsonl.read_jsonl(Jsonl.get_npc_corps_path) |> Enum.map(fn nc -> nc["_key"] end)
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps, fn id ->
     {id, Utils.fetch_from_url!(@loyalty_offer_url<>Integer.to_string(id)<>"/offers")}
    end) |>  Enum.map(fn {:ok, {id, offer}} -> {id, offer} end)

  end
end
