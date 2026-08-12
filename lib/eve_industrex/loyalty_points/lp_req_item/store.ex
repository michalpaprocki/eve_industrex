defmodule EveIndustrex.LoyaltyPoints.LpReqItem.Store do
  @moduledoc false

  def get_offers_by_req_item(type_id) do
    :ets.tab2list(:lp_offers)
    |> Enum.filter(fn {_id, o} -> Enum.any?(o.req_items, fn ri -> ri.type_id == type_id end) end)
    |> Enum.map(fn {id, o} -> %{type_id: o.type_id, name: o.name, offer_id: id} end)
    |> Enum.sort_by(& &1.name, :asc)
  end
end
