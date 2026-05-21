defmodule EveIndustrex.LoyaltyPoints.LpOffer.Persistence do
LoyaltyPoints
  alias EveIndustrex.LoyaltyPoints.LpOffer
  alias EveIndustrex.Repo

  def upsert_all(list_of_lp_offers, return? \\ false) when is_list(list_of_lp_offers) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_lp_offers, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      LpOffer,
      rows,
      on_conflict: {:replace, [:lp_cost, :isk_cost, :updated_at, :quantity, :type_id]},
      conflict_target: :offer_id,
      returning: return?
    )
  end

  def upsert(station) do
    %LpOffer{}
    |> LpOffer.changeset(station)
    |> Repo.insert(on_conflict: {:replace, [:lp_cost, :isk_cost, :updated_at, :quantity, :type_id]}, conflict_target: :offer_id)
  end

end
