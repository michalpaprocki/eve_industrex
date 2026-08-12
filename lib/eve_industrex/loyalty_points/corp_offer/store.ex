defmodule EveIndustrex.LoyaltyPoints.CorpOffer.Store do
  alias EveIndustrex.LoyaltyPoints.NpcCorp
  @moduledoc false
  def get_corp_offer(corp_id) do
    :ets.lookup(:corp_offers, corp_id)
  end

  def get_all() do
    :ets.tab2list(:corp_offers)
  end

  def get_corps_by_offer(offer_id) do
    get_all()
    |> Enum.filter(fn {_k, v} ->
      Enum.member?(v, offer_id)
    end)
    |> Enum.map(fn {id, _o} -> NpcCorp.Store.get_corp_by_corp_id(id) end)
  end
end
