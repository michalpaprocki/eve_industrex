defmodule EveIndustrex.LoyaltyPoints.NpcCorp.Store do
  @moduledoc false
  def get_all(), do: :ets.tab2list(:npc_corps)
end
