defmodule EveIndustrex.ESI.Corporations do
  alias EveIndustrex.Logger.EiLogger
  alias EveIndustrex.Corporation
  alias EveIndustrex.Utils
  @npc_corps_url "https://esi.evetech.net/latest/corporations/npccorps/"
  @corp_info_url "https://esi.evetech.net/latest/corporations/"
  @loyalty_offer_url "https://esi.evetech.net/latest/loyalty/stores/"
  def fetch_npc_corps() do
    case Utils.fetch_from_url(@npc_corps_url) do
      {:error, error} ->
        {:error, error}
      {:ok, npc_corps_ids} ->
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps_ids, fn id ->
          {id, Utils.fetch_from_url!(@corp_info_url<>Integer.to_string(id))}
        end) |> Enum.map(fn x -> elem(x, 1) end)
    end
  end
  def fetch_npc_corps!() do
    case Utils.can_fetch?(@npc_corps_url) do
      true ->
        npc_corps_ids = Utils.fetch_from_url!(@npc_corps_url)
        Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps_ids, fn id ->
          {id, Utils.fetch_from_url!(@corp_info_url<>Integer.to_string(id))}
        end) |> Enum.map(fn x -> elem(x, 1) end)
      {false, error} ->
        EiLogger.log(:error, error)
        raise "Could not initiate fetching"
    end

  end
  def fetch_lp_offers_from_ESI() do
    npc_corps_ids = Corporation.get_npc_corps_ids()
    if length(npc_corps_ids) == 0 do
      fun = Function.info(&fetch_lp_offers_from_ESI/0)
      {:error,{:enoent, "Missing entities required", "#{Keyword.get(fun, :module)}"<>":#{Keyword.get(fun, :name)}"<>"/#{Keyword.get(fun, :arity)}"}}
    else
      case Utils.can_fetch?(@loyalty_offer_url<>~s"#{hd(npc_corps_ids)}"<>"/offers/") do
        {false, error} ->
          {:error, error}
        true ->
         Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps_ids, fn id -> {id, Utils.fetch_from_url!(@loyalty_offer_url<>Integer.to_string(id)<>"/offers/")} end) |> Enum.map(fn x -> elem(x, 1) end)
      end
    end
  end
   def fetch_lp_offers_from_ESI!() do
     npc_corps_ids = Corporation.get_npc_corps_ids()
    if length(npc_corps_ids) == 0 do
      fun = Function.info(&fetch_lp_offers_from_ESI!/0)
        EiLogger.log(:error,{:enoent, "Missing entities required", "#{Keyword.get(fun, :module)}"<>":#{Keyword.get(fun, :name)}"<>"/#{Keyword.get(fun, :arity)}"})
        raise "Missing entities required"
    else
      case Utils.can_fetch?(@loyalty_offer_url<>~s"#{hd(npc_corps_ids)}"<>"/offers/") do
        {false, error} ->
          EiLogger.log(:error, error)
          raise "Could not initiate fetching"
        true ->
         Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, npc_corps_ids, fn id -> {id, Utils.fetch_from_url!(@loyalty_offer_url<>Integer.to_string(id)<>"/offers/")} end) |> Enum.map(fn x -> elem(x, 1) end)
      end
    end
   end
end
