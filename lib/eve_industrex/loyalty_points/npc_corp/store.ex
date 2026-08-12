defmodule EveIndustrex.LoyaltyPoints.NpcCorp.Store do
  @moduledoc false
  def get_all(), do: :ets.tab2list(:npc_corps)

  def get_corp_by_corp_id(corp_id) do
    case :ets.lookup(:npc_corps, corp_id) do
      [] ->
        []

      [{^corp_id, rest}] ->
        rest
    end
  end
end
