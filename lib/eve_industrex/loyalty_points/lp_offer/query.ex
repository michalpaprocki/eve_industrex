defmodule EveIndustrex.LoyaltyPoints.LpOffer.Query do
  alias EveIndustrex.LoyaltyPoints.LpOffer
  alias EveIndustrex.Repo
  import Ecto.Query

  def get_offers(), do: Repo.all(LpOffer) |> Repo.preload([:req_items, :type])
end
