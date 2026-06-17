defmodule EveIndustrex.LoyaltyPoints.NpcCorp.Query do
  alias EveIndustrex.LoyaltyPoints.{NpcCorp, LpOffer, CorpOffer}
  alias EveIndustrex.LoyaltyPoints.NpcCorp.Store
  alias EveIndustrex.Repo
  import Ecto.Query


  def get_corp(id), do: Store.get_all() |> Enum.filter(fn {_cid, corp} -> corp.corp_id == id end)
  def corps_with_offers(), do: Store.get_all() |> Enum.map(&elem(&1, 1)) |> Enum.sort(&(&1.name < &2.name))
  def get_corps_with_offers(), do: from(c in NpcCorp, join: o in assoc(c, :offers), distinct: true, order_by: [asc: c.name], select: {c.corp_id, %{corp_id: c.corp_id, name: c.name}}) |> Repo.all()
  def get_corp_offer_ids(corp_id) do
    ids = from(c in NpcCorp, join: o in assoc(c, :offers), where: c.corp_id == ^corp_id, select: o.offer_id) |> Repo.all()
    {corp_id, ids}
  end
end
