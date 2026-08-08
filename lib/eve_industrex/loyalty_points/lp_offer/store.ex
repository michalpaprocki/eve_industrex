defmodule EveIndustrex.LoyaltyPoints.LpOffer.Store do
  @moduledoc false
  def get_all(), do: :ets.tab2list(:lp_offers)

  def get_offer(offer_id) do
    :ets.lookup(:lp_offers, offer_id)
  end

  def get_offers_rewards() do
    :ets.tab2list(:lp_offers)
    |> Enum.map(fn {_id, o} -> %{name: o.name, type_id: o.type_id} end)
    |> Enum.uniq()
  end
end
