defmodule EveIndustrex.Market.MarketOrder.Persistence do
  alias EveIndustrex.Universe.Constellation
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Universe.Station
  alias EveIndustrex.Universe.Region
  alias EveIndustrex.Universe
  alias EveIndustrex.Repo
  alias EveIndustrex.Market.MarketOrder
  import Ecto.Query

  def upsert_all(list_of_market_orders, return? \\ false) do

      now = DateTime.utc_now() |> DateTime.truncate(:second)
      rows = Enum.map(list_of_market_orders, fn mo ->

      Map.merge(mo, %{
        inserted_at: now,
        updated_at: now
      })

    end)
    Repo.insert_all(
      MarketOrder,
      rows,
      on_conflict: {:replace_all_except, [:order_id, :inserted_at]},
      conflict_target: :order_id,
      returning: return?
    )
  end
  def delete_all() do
    Repo.delete_all(MarketOrder)
  end
  def put_location_assoc(location_id) do
    case Universe.Station.Store.get_station(location_id) do
      {station_id, _system_id, _name, :station} ->
        %{station_id: station_id}
      [] ->
        # structure in future
        %{}
    end
  end
  def delete_all_from_prev_gen(region_id, generation) do
    from(mo in MarketOrder,
    where: mo.region_id == ^region_id and mo.generation < ^generation)
    |> Repo.delete_all()
  end

end
