defmodule EveIndustrex.Infrastructure.Cache.Loader.CorpOffers do
  alias EveIndustrex.LoyaltyPoints
  def init() do
    corp_offers = LoyaltyPoints.NpcCorp.Store.get_all()
    |> Enum.map(fn x -> LoyaltyPoints.CorpOffer.Query.get_corp_offers_for_cache(elem(x,0)) end)
    |> List.flatten()
    |> Enum.map(fn {corp_id, offers} ->
{corp_id,
      Enum.map(offers, fn o ->
         %{
          type: %{
            type_id: o.offer.type.type_id,
            name: o.offer.type.name,
            portion_size: o.offer.type.portion_size
          },
          isk_cost: o.offer.isk_cost,
          lp_cost: o.offer.lp_cost,
          offer_id: o.offer_id,
          quantity: o.offer.quantity,
          req_items: Enum.map(o.offer.req_items, fn ri ->
                    %{
                      quantity: ri.quantity,
                      type_id: ri.type_id,
                      name: ri.type.name,
                      category_id: ri.type.group.category_id
                    }
                    end)
        }
      end)
      }
    end)
    |> List.flatten()
    :ets.insert(:corp_offers, corp_offers)
  end
end
