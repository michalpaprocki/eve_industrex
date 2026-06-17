defmodule EveIndustrex.LoyaltyPoints.LpOffer.Query do
  alias EveIndustrex.LoyaltyPoints.LpOffer
  alias EveIndustrex.Repo
  import Ecto.Query

  def get_offers_for_cache(), do: Repo.all(LpOffer) |> Repo.preload([:req_items, :type]) |> Enum.map(fn x ->
    {
      x.offer_id, %{
        isk_cost: x.isk_cost,
        lp_cost: x.lp_cost,
        quantity: x.quantity,
        offer_id: x.offer_id,
        type_id: x.type_id,
        name: x.type.name,
        req_items: Enum.map(x.req_items, fn ri ->
          %{type_id: ri.type_id, quantity: ri.quantity}
        end)
      }
    }
  end)
end
