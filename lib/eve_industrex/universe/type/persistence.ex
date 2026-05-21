defmodule EveIndustrex.Universe.Type.Persistence do
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Type

  def upsert_all(list_of_types, return? \\ false) when is_list(list_of_types) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_types, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      Type,
      rows,
      on_conflict: {:replace, [:capacity, :updated_at, :description, :icon_id, :mass, :name, :packaged_volume, :portion_size, :published, :radius, :volume, :group_id, :market_group_id]},
      conflict_target: :type_id,
      returning: return?
    )
  end

  def upsert(type) do
    %Type{}
    |> Type.changeset(type)
    |> Repo.insert(on_conflict: {:replace, [:capacity, :updated_at, :description, :icon_id, :mass, :name, :packaged_volume, :portion_size, :published, :radius, :volume, :group_id, :market_group_id]}, conflict_target: :type_id)
  end

end
