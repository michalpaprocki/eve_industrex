defmodule EveIndustrex.Types do
  alias EveIndustrex.Parser
  alias EveIndustrex.Schemas.Group
  alias EveIndustrex.Schemas.Blueprint
  alias EveIndustrex.Schemas.Type
  alias EveIndustrex.Schemas.MarketGroup
  alias EveIndustrex.ESI.Types
  alias EveIndustrex.Repo
  import Ecto.Query

  def update_market_groups() do
    market_groups = Types.fetch_market_groups()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor,market_groups, fn {_status, mg} ->
      %MarketGroup{}
      |> MarketGroup.changeset(mg)
      |> Repo.insert_or_update()
    end) |> Stream.run()
  end

  def get_market_groups() do
    top_groups = Enum.sort(Enum.map(get_market_groups_without_parent(), fn m -> prep_map(m) end ), &(&1.name < &2.name))
    with_parents = get_market_groups_with_parents()
    first_wave = Enum.map(top_groups, fn tg -> Map.put(tg, :children, prep_map(Enum.sort(Enum.filter(with_parents, fn wp -> tg.market_group_id == wp.parent_group_id end), &(&1.name < &2.name))))end)
    second_wave = Enum.map(first_wave, fn fw -> Map.replace(fw, :children, Enum.map(fw.children, fn c -> Map.replace(c, :children, prep_map(Enum.sort(Enum.filter(with_parents, fn wp -> c.market_group_id == wp.parent_group_id end), &(&1.name < &2.name)))) end)) end)
    third_wave = Enum.map(second_wave, fn sw -> Map.replace(sw, :children, Enum.map(sw.children, fn fw -> Map.replace(fw, :children, Enum.map(fw.children, fn c -> Map.replace(c, :children, prep_map(Enum.sort(Enum.filter(with_parents, fn wp -> c.market_group_id == wp.parent_group_id end), &(&1.name > &2.name)))) end) )end))end)
    fourth_wave = Enum.map(third_wave, fn tw -> Map.replace(tw,:children, Enum.map(tw.children, fn sw -> Map.replace(sw, :children, Enum.map(sw.children, fn fw -> Map.replace(fw, :children, Enum.map(fw.children, fn c -> Map.replace(c, :children, prep_map(Enum.sort(Enum.filter(with_parents, fn wp -> c.market_group_id == wp.parent_group_id end), &(&1.name > &2.name))))end) )end)) end)) end)
    fourth_wave
  end
  def add_type(id) do
    t = Types.fetch_type(id)

       case get_market_group(t["market_group_id"]) do
        nil ->
          case get_type(t["type_id"]) do
            nil ->
            %Type{}
            type ->
              type
          end
            found_market_group ->
         case get_type(t["type_id"]) do
           nil ->
            %Type{}
            |> Ecto.Changeset.change(market_group_id: found_market_group.market_group_id)
          type ->
            type
         end
      end
      |> Type.changeset(t)
      |> Repo.insert_or_update()
  end
  def update_types_from_ESI() do
    types = Types.fetch_types()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, types, fn {_status, t} ->

      case get_market_group(t["market_group_id"]) do
        nil ->
          case get_type(t["type_id"]) do
            nil ->
            %Type{}
            type ->
              type
          end
            found_market_group ->
         case get_type(t["type_id"]) do
           nil ->
            %Type{}
            |> Ecto.Changeset.change(market_group_id: found_market_group.market_group_id)
          type ->
            type
         end
      end
      |> Type.changeset(t)
      |> Repo.insert_or_update()
    end) |> Stream.run()
  end
  def update_types_from_dump() do
    dumped_types = Parser.parse_types()
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, dumped_types, fn t ->
    case get_type(elem(t, 0)) do
      nil ->
        %Type{}
      type ->
        type
      end
      |> Type.changeset(%{
        :type_id => elem(t, 0),
        :capacity => elem(List.keyfind(elem(t, 1), "capacity", 0, {nil, nil}), 1),
        :description => extract_description(t),
        :icon_id => elem(List.keyfind(elem(t, 1), "iconID", 0, {nil, nil}), 1),
        :mass => elem(List.keyfind(elem(t, 1), "mass", 0, {nil, nil}), 1),
        :name => elem(List.keyfind(elem(t, 1), "name", 0, {nil, nil}), 1),
        :packaged_volume => elem(List.keyfind(elem(t, 1), "packaged_volume", 0, {nil, nil}), 1),
        :portion_size => elem(List.keyfind(elem(t, 1), "portion_size", 0, {nil, nil}), 1),
        :published => elem(List.keyfind(elem(t, 1), "published", 0, {nil, nil}), 1),
        :radius => elem(List.keyfind(elem(t, 1), "radius", 0, {nil, nil}), 1),
        :volume => elem(List.keyfind(elem(t, 1), "volume", 0, {nil, nil}), 1),
        :group_id => elem(List.keyfind(elem(t, 1), "group_id", 0, {nil, nil}), 1),
        :market_group_id => elem(List.keyfind(elem(t, 1), "market_group_id", 0, {nil, nil}), 1),
      })
      |> Repo.insert_or_update()
    end) |> Stream.run()
  end
  def get_type_with_mats(id) do

    from(t in Type, where: t.type_id == ^id, preload: :materials) |> Repo.all
  end
  def get_type_product(id) do
    from(t in Type, where: t.type_id ==^id, preload: [:products]) |> Repo.all
  end
  def get_type(id) when is_integer(id), do: Repo.get_by(Type, type_id: id)
  def get_type(id) when is_binary(id), do: Repo.get_by(Type, type_id: String.to_integer(id))
  def get_type_name(id) when is_integer(id), do: from(from t in Type, where: t.type_id == ^id, select: [t.name, t.type_id]) |> Repo.all() |> hd()
  def get_all_types(), do: from(t in Type, preload: [:market_group]) |> Repo.all
  def get_types_count(), do: from(t in Type) |> Repo.aggregate(:count)
  def get_types_from_list_of_ids(list_of_type_ids) do
    from(t in Type, where: t.type_id in ^list_of_type_ids)|> Repo.all
  end
  def get_types_by_market_group(market_group_id) do
    from(t in Type, where: t.market_group_id == ^market_group_id) |> Repo.all()
  end
  def get_market_group(nil), do: nil
  def get_market_group(id), do: Repo.get_by(MarketGroup, market_group_id: id)
  def get_market_groups_with_types(), do: from(m in MarketGroup, where: m.types != []) |> Repo.all
  def get_market_group_by_parent(parent_id), do: from(m in MarketGroup, where: m.parent_group_id == ^parent_id) |> Repo.all
  def get_market_groups_with_parents() do
    from(m in MarketGroup, where: not is_nil(m.parent_group_id), preload: :types, left_join: t in Type, on: m.market_group_id == t.market_group_id, preload: [types: t]) |> Repo.all
  end
  def get_types_by_query(query) when is_binary(query) do
    from(t in Type, where: ilike(t.name, ^"%#{query}%") and not is_nil(t.market_group_id) and t.published == true, order_by: [asc: t.name] ) |> Repo.all
  end
  def get_type_by_name(name) do
    Repo.get_by(Type, name: name)
  end
  def get_market_groups_without_parent(), do: from(m in MarketGroup, where: is_nil(m.parent_group_id)) |> Repo.all
  def get_all_market_groups(), do: Repo.all(MarketGroup)
  def get_formulas() do
    from(t in Type, where: ilike(t.name, "%unrefined%") and ilike(t.name, "%formula%"), select: [t.type_id, t.name], order_by: [asc: t.type_id]) |> Repo.all
  end
  def get_reactions() do
    from(t in Type, where: not ilike(t.name, "%unrefined%") and ilike(t.name, "%formula") and t.published == true and not is_nil(t.market_group_id), select: [t.type_id, t.name], order_by: [asc: t.type_id]) |> Repo.all
  end
  defp prep_map(data) when is_list(data) do
    Enum.map(data, fn d -> prep_map(d) end)
  end

  defp prep_map(data) do
   children =  if Map.has_key?(data, :children), do: data.children, else: []
   types =  if Map.has_key?(data, :types), do: data.types, else: []
    %{:name => data.name, :description => data.description, :market_group_id => data.market_group_id, :parent_group_id => data.parent_group_id, :children => children, :types =>  types}
  end

  def get_bp_by_type_id(type_id) do
    Repo.get_by(Blueprint, blueprintTypeID: type_id)
  end
  def get_bps_product(type_id) do
    bp = Repo.get_by(Blueprint, blueprintTypeID: type_id)
    activities = :erlang.binary_to_term(bp.activities)
    manufacturing = Enum.filter(activities, fn a -> String.contains?(elem(a, 0), "manufacturing") end)
    Enum.filter(elem(hd(manufacturing), 1), fn m -> String.contains?(elem(m, 0), "product") end) |> hd() |> elem(1) |> hd()
  end
  def get_bps_from_id_list(type_ids) do
    from(b in Blueprint, where: b.blueprint_type_id in ^type_ids, order_by: [asc: b.blueprint_type_id]) |> Repo.all
  end
  def get_all_blueprints() do
    from(t in Type, where: ilike(t.name, "%blueprint%") and t.published == true, join: g in Group, on: t.group_id == g.group_id, group_by: [t.group_id, g.name, t.name, t.type_id, t.id], order_by: [asc: :group_id]) |> Repo.all() |> Repo.preload(:group)
  end
  def read_bps_all() do
    Repo.all(Blueprint)
  end

  def remove_bps_all(), do: Repo.delete_all(Blueprint)
  def remove_types_all(), do: Repo.delete_all(Type)


  defp extract_description(type) do
    if List.keyfind(elem(type, 1), "description", 0, nil) do
      List.keyfind(elem(List.keyfind(elem(type, 1), "description", 0, {nil, nil}), 1), :en, 0, {nil, nil})
     else
      nil
    end
  end

end
