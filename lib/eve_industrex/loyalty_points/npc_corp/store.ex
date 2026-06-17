defmodule EveIndustrex.LoyaltyPoints.NpcCorp.Store do

  def get_all(), do: :ets.tab2list(:npc_corps)

end
