defmodule EveIndustrex.LoyaltyPoints.LpOffer.Store do
  alias EveIndustrex.Universe.Type
  @moduledoc false
  def get_all(), do: :ets.tab2list(:lp_offers)

  def get_offer(offer_id) do
    case :ets.lookup(:lp_offers, offer_id) do
      [] ->
        []

      [{key, offer}] ->
        req_items =
          Enum.map(offer.req_items, fn ri ->
            Map.put(
              ri,
              :name,
              Type.Store.get_type_id_details(ri.type_id)[:name]
            )
            |> Map.put(:category_id, Type.Store.get_type_id_details(ri.type_id)[:category_id])
          end)

        {key, %{offer | req_items: req_items}}
    end
  end
end
