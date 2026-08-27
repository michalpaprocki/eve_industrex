defmodule EveIndustrex.LoyaltyPoints.Composer do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Industry
  alias EveIndustrex.LoyaltyPoints

  @moduledoc """
    Composer assembles a ready map for LP liveview consumption.
  """
  def lp_shop_view(corp_id) do
    offer_ids = LoyaltyPoints.CorpOffer.Query.get_corp_offers(corp_id)

    offers =
      Enum.map(elem(offer_ids, 1), fn id ->
        LoyaltyPoints.LpOffer.Store.get_offer(id) |> elem(1)
      end)

    bps =
      get_offer_blueprints(offers)
      |> Enum.map(fn {id, bp} ->
        Industry.Production.Composer.compose_from_bp({id, bp})
      end)
      |> List.flatten()
      |> Map.new(fn {k, v} -> {k, v} end)

    Enum.map(offers, fn offer ->
      case Map.get(bps, offer.type_id) do
        nil ->
          offer
          |> put_in(
            [:category_id],
            Type.Store.get_type_id_details(offer.type_id).category_id
          )
          |> put_in(
            [:category],
            Type.Store.get_type_id_details(offer.type_id).category
          )
          |> put_in([:group], Type.Store.get_type_id_details(offer.type_id).group)

        bp ->
          Map.put(offer, :blueprint, bp)
          |> put_in(
            [:category_id],
            Type.Store.get_type_id_details(offer.type_id).category_id
          )
          |> put_in(
            [:category],
            Type.Store.get_type_id_details(offer.type_id).category
          )
          |> put_in([:group], Type.Store.get_type_id_details(offer.type_id).group)
      end
    end)
    |> Map.new(fn o ->
      {o.offer_id, o}
    end)
  end

  defp get_offer_blueprints(offers) do
    Enum.filter(offers, fn o ->
      String.contains?(String.downcase(o.name), "blueprint") and
        !String.contains?(String.downcase(o.name), "crate")
    end)
    |> Enum.map(fn bp -> {bp.type_id, Type.Store.get_type_id_details(bp.type_id)} end)
  end
end
