defmodule EveIndustrex.Universe.MarketGroup.Query do
  import Ecto.Query
  alias EveIndustrex.Universe.MarketGroup
  alias EveIndustrex.Repo

  def get_market_groups_for_cache(), do: from(mg in MarketGroup, where: is_nil(mg.parent_group_id), order_by: [asc: mg.name], select: {mg.market_group_id, mg.name
    }) |> Repo.all


  def get_market_groups_children_for_cache(), do: from(mg in MarketGroup, where: not is_nil(mg.parent_group_id)) |> Repo.all
  |> Enum.map(fn mg ->
  {mg.parent_group_id,
    %{
      market_group_id: mg.market_group_id,
      name: mg.name,
      }
    }
  end)
  def get_market_groups_types do
    from(mg in MarketGroup, where: not is_nil(mg.parent_group_id), join: t in assoc(mg, :types), where: t.published == true , distinct: mg.market_group_id) |> Repo.all() |> Repo.preload(:types)
    |> Enum.map(fn mg ->
      {mg.market_group_id, Enum.map(mg.types, fn t -> %{type_id: t.type_id, name: t.name} end)}
    end)
  end
  def get_market_group(id), do: Repo.get_by(MarketGroup, market_group_id: id)
  def get_market_groups_with_parents(), do: from(mg in MarketGroup, where: not is_nil(mg.parent_group_id)) |> Repo.all

end
