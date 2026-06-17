defmodule EveIndustrex.Universe.MarketGroup.Query do
  import Ecto.Query
  alias EveIndustrex.Universe.MarketGroup.Store
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Universe.MarketGroup
  alias EveIndustrex.Repo

  def get_market_groups_for_cache(), do: from(mg in MarketGroup, where: is_nil(mg.parent_group_id), order_by: [asc: mg.name], select: {mg.market_group_id, mg.name
    }) |> Repo.all
  def get_all(), do: Repo.all(MarketGroup)

  def get_market_groups_children_for_cache(), do: from(mg in MarketGroup, where: not is_nil(mg.parent_group_id)) |> Repo.all
  |> Enum.map(fn mg ->
  {mg.parent_group_id,
    %{
      market_group_id: mg.market_group_id,
      name: mg.name,
      }
    }
  end)
  def get_market_groups_types() do
    from(mg in MarketGroup, where: not is_nil(mg.parent_group_id), join: t in Type, on: mg.market_group_id == t.market_group_id and t.published == true,  select: {mg.market_group_id, %{type_id: t.type_id,name: t.name}}) |> Repo.all()
  end
  def get_market_groups_types_lookup() do
    from(mg in MarketGroup, where: not is_nil(mg.parent_group_id), join: t in Type, on: mg.market_group_id == t.market_group_id and t.published == true,  select: {t.type_id, t.name}) |> Repo.all()
  end
  def get_market_group(id), do: Repo.get_by(MarketGroup, market_group_id: id)

  def get_market_groups_with_parents(), do: from(mg in MarketGroup, where: not is_nil(mg.parent_group_id)) |> Repo.all
  def get_market_types_by_query(query) do
    Store.get_types() |> Enum.filter(fn {_market_group, type} -> String.contains?(String.downcase(type.name), query) end) |> Enum.map(fn {market_group, type} -> type end)
  end
end
