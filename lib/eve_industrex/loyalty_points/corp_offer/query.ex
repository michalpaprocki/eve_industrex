defmodule EveIndustrex.LoyaltyPoints.CorpOffer.Query do
  alias EveIndustrex.LoyaltyPoints.CorpOffer
  alias EveIndustrex.Repo
  import Ecto.Query
  def get_db_count(), do: Repo.aggregate(CorpOffer, :count)
  def get_corp_offers_for_cache(corp_id) do
    offers = from(c in CorpOffer, join: o in assoc(c, :offer), where: c.corp_id == ^corp_id,
     preload: [:offer, offer: [:type, :req_items, req_items: [:type, type: [:group]]]]) |> Repo.all()
    {corp_id, offers}
  end
  def get_corp_offers(corp_id) do
    case CorpOffer.Store.get_corp_offer(corp_id) do
      [{^corp_id, offers}] ->
        offers
      [] ->
        []
    end
  end
end
