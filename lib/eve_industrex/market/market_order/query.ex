defmodule EveIndustrex.Market.MarketOrder.Query do
  import Ecto.Query

  alias EveIndustrex.Market.MarketOrder
  alias EveIndustrex.Repo
  require Logger

  def get_count(), do: Repo.aggregate(MarketOrder, :count)
  def get_by_region(region_id) do
    from(mo in MarketOrder, where: mo.region_id == ^region_id) |> Repo.all
  end
  def delete_all() do
    Repo.delete_all(MarketOrder)
  end
  def get_without_station() do
    from(mo in MarketOrder, where: is_nil(mo.station_id)) |> Repo.all
  end
  def get_with_station() do
    from(mo in MarketOrder, where: not is_nil(mo.station_id)) |> Repo.all
  end
  def get_fresh_gen_orders_by_region(region_id) do
    max_gen = from(mo in MarketOrder, select: max(mo.generation))
    from(mo in MarketOrder, where: mo.generation == subquery(max_gen) and mo.region_id == ^region_id)
    |> Repo.all
  end
  def get_all_count(), do: Repo.aggregate(MarketOrder, :count)


end
