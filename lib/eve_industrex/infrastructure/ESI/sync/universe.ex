defmodule EveIndustrex.Infrastructure.ESI.Sync.Universe do
alias EveIndustrex.Universe.MarketGroup
alias EveIndustrex.Universe.Category
alias EveIndustrex.Universe.Group
alias EveIndustrex.Infrastructure.ESI.Sync.SyncEvents
alias EveIndustrex.Infrastructure.ESI.ClientHandler
alias EveIndustrex.Universe.Type
alias EveIndustrex.Infrastructure.ESI.Client
alias EveIndustrex.Repo
# this needs a huge refactor to accomodate headers
  require Logger
  def ensure_type_dependencies(type_ids) do
   with {:ok, missing_types} <- resolve_dependencies(type_ids, &Type.Store.filter_unknown/1, &Client.fetch_type/1, &Type.Mapper.from_esi/1),
          group_ids = extract_group_ids(missing_types),
          SyncEvents.dependencies_imported(length(missing_types), :type),
          market_group_ids = extract_market_group_ids(missing_types),

        {:ok, missing_groups} <- resolve_dependencies(group_ids, &Group.Store.filter_unknown/1, &Client.fetch_group/1, &Group.Mapper.from_esi/1),
          category_ids = extract_category_ids(missing_groups),
          SyncEvents.dependencies_imported(length(missing_groups), :group),
        {:ok, missing_categories} <- resolve_dependencies(category_ids, &Category.Store.filter_unknown/1, &Client.fetch_category/1, &Category.Mapper.from_esi/1),
          SyncEvents.dependencies_imported(length(missing_categories), :category),
        {:ok, missing_market_groups} <- resolve_dependencies(market_group_ids, &MarketGroup.Store.filter_unknown/1, &Client.fetch_market_group/1, &MarketGroup.Mapper.from_esi/1),
        SyncEvents.dependencies_imported(length(missing_market_groups), :market_group) do
          persist(%{types: missing_types, groups: missing_groups, categories: missing_categories, market_groups: missing_market_groups})

         end

  end
  def persist(%{types: types, groups: groups, categories: categories, market_groups: market_groups}) do
     Repo.transaction(fn ->
            Category.Persistence.upsert_all(categories)
            Group.Persistence.upsert_all(groups)
            MarketGroup.Persistence.upsert_all(market_groups)
            Type.Persistence.upsert_all(types)
            # MarketGroup.Persistence.put_mg_assocs()
      end)
    |> case do
       {:ok, _} ->
        {categories, groups, market_groups, types}

      {:error, err} ->
        {:error, {:transaction_failed, err}}
     end
  end

  def update_caches({categories, groups, market_groups, types}) do


    Enum.map(categories, fn c -> Category.Mapper.to_projection(c) |> Category.Store.add() end)
    Enum.map(groups, fn g -> Group.Mapper.to_projection(g) |> Group.Store.add() end)
    Enum.map(market_groups, fn mg -> if mg.parent_group_id == nil, do: MarketGroup.Mapper.to_projection_parent(mg) |> MarketGroup.Store.add_parent(), else: MarketGroup.Mapper.to_projection_child(mg) |> MarketGroup.Store.add_children() end)

    Enum.map(types, fn t -> Type.Mapper.to_projection(t) |> Type.Store.add() end)

  end
  defp resolve_dependencies(ids, filter_fn, fetch_fn, mapper_fn) do
    case filter_fn.(ids) do
      [] ->
        {:ok, []}
      missing ->
          with {:ok, bodies} <- fetch_all(missing, fetch_fn) do
            {:ok, Enum.map(bodies, mapper_fn)}
          end

    end
  end


  defp fetch_all(ids, fetch_fn) do
    Enum.reduce_while(ids, {:ok, []}, fn id, {:ok, acc} ->
      Logger.info("calling fetch fn with #{inspect(id)}")
      case ClientHandler.handle_response(fetch_fn.(id)) do
        {:success, body, _headers} ->

          {:cont, {:ok, [body | acc]}}
        error ->
          {:halt, {:error, {id, error}}}
      end
    end)
  end
  defp extract_group_ids(types) do
    Enum.map(types, fn t -> t.group_id end) |> Enum.uniq()
  end
  defp extract_market_group_ids(types) do
    Enum.map(types, fn t -> t.market_group_id end) |> Enum.uniq()
  end
  defp extract_category_ids(groups) do
    Enum.map(groups, fn g -> g.category_id end) |> Enum.uniq()
  end
end
