defmodule EveIndustrex.LoyaltyPoints.NpcCorp.Persistence do
  alias EveIndustrex.LoyaltyPoints.NpcCorp
  alias EveIndustrex.Repo

  def upsert_all(list_of_npc_corps, return? \\ false) when is_list(list_of_npc_corps) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_npc_corps, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      NpcCorp,
      rows,
      on_conflict: {:replace, [:name, :description, :updated_at]},
      conflict_target: :corp_id,
      returning: return?
    )
  end

  def upsert(station) do
    %NpcCorp{}
    |> NpcCorp.changeset(station)
    |> Repo.insert(on_conflict: {:replace, [:name, :description, :updated_at]}, conflict_target: :corp_id)
  end
end
