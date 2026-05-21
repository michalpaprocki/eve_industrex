defmodule EveIndustrex.LoyaltyPoints.LpReqItem.Persistence do
  alias EveIndustrex.LoyaltyPoints.LpReqItem
  alias EveIndustrex.Repo

  def insert_all(list_of_req_items, return? \\ false) when is_list(list_of_req_items) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_req_items, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      LpReqItem,
      rows,
      returning: return?
    )
  end

  def insert(req_item) do
    %LpReqItem{}
    |> LpReqItem.changeset(req_item)
    |> Repo.insert()
  end
  def delete_all(), do: Repo.delete_all(LpReqItem)
end
