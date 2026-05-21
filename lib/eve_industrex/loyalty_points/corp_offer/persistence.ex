defmodule EveIndustrex.LoyaltyPoints.CorpOffer.Persistence do
  alias EveIndustrex.LoyaltyPoints.CorpOffer
  alias EveIndustrex.Repo

  def upsert_all(corps_offers) do
    rows =
      for {cid, offer_ids} <- corps_offers,
          offer_id <- offer_ids do
          %{
              corp_id: cid,
              offer_id: offer_id
            }
      end

    Repo.insert_all(
      CorpOffer,
      rows,
      on_conflict: :nothing,
      conflict_target: [:corp_id, :offer_id]
    )
  end
end
