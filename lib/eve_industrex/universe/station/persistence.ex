defmodule EveIndustrex.Universe.Station.Persistence do

  @trade_hubs [60003760,60008494,60011866,60004588,60005686]
  alias EveIndustrex.Repo
  alias EveIndustrex.Universe.Station
  def upsert_all(list_of_stations, return? \\ false) when is_list(list_of_stations) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    rows = Enum.map(list_of_stations, fn r ->
      Map.merge(r, %{
        inserted_at: now,
        updated_at: now
      })
    end)
    Repo.insert_all(
      Station,
      rows,
      on_conflict: {:replace, [:name, :reprocessing_efficiency, :reprocessing_stations_take, :system_id, :updated_at, :services]},
      conflict_target: :station_id,
      returning: return?
    )
  end

  def upsert(station) do
    %Station{}
    |> Station.changeset(station)
    |> Repo.insert(on_conflict: {:replace, [:name, :reprocessing_efficiency, :reprocessing_stations_take, :system_id, :updated_at, :services]}, conflict_target: :station_id)
  end
end
