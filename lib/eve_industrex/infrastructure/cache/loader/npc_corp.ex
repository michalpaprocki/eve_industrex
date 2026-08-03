defmodule EveIndustrex.Infrastructure.Cache.Loader.NpcCorp do
  alias EveIndustrex.LoyaltyPoints.NpcCorp.Query
  @moduledoc false
  def init(), do: :ets.insert(:npc_corps, Query.get_corps_with_offers())
end
