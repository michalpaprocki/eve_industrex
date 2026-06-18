defmodule EveIndustrex.Infrastructure.ESI.Sync.OrchestratorService do
  require Logger
  alias EveIndustrex.Infrastructure.ESI.ClientHandler
  alias EveIndustrex.Infrastructure.ESI.Headers
  alias EveIndustrex.Infrastructure.ESI.Sync.{EsiSyncGeneration, EsiSyncStrategy}
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Market.MarketOrder
  alias EveIndustrex.Infrastructure.ESI.RouteGroups
  alias EveIndustrex.Infrastructure.ESI.EtagStore
  alias EveIndustrex.Infrastructure.ESI.RateLimiter
  def orchestrate(fetch_fn, generation_id, generation, attempt, strategy, metadata, page) do
    # possible egde case when etag expires during fn call/ maybe use duration_ms from generations to estimate what's the appropriate window / or save etag in db and check if incoming etag same as this in db

    case ClientHandler.handle_response(fetch_fn.(strategy.target_id, page, metadata)) do
            {:success, body, %Headers{} = headers} ->
              if page == 1 do

                EtagStore.upsert_metadata(headers.rate_limit_group, strategy.target_id, headers)

              end

              RateLimiter.observe(headers)

              upsert_sync_gen_page(page, generation_id, :completed, attempt)

              upsert(body, strategy.resource_type.name, generation, strategy.target_id)

              if page == 1 do
                maybe_update_route_group(strategy.resource_type.name, headers.rate_limit_group)
              end
              advance_page_completed(generation_id, String.to_integer(headers.pages))
              cond do
                String.to_integer(headers.pages) > 1 && page == 1 ->
                  {:fanout, String.to_integer(headers.pages)}

                page == 1 ->
                  {:ok, String.to_integer(headers.pages), generation_id}
                true ->

                  :ok

              end


            {:rate_limited, %Headers{} = headers} ->
              upsert_sync_gen_page(page, generation_id, :rate_limited, attempt)

              RateLimiter.cooldown(headers)
              {:snooze, calc_delay(attempt)}

            {:not_modified, %Headers{} = headers} ->

              Logger.info("NOT MODDED")

              upsert_sync_gen_page(page, generation_id, :matched, attempt)

              RateLimiter.observe(headers)
              if page == 1 do
                maybe_update_route_group(strategy.resource_type.name, headers.rate_limit_group)
              end

                update_generation(generation_id, %{
                  status: :completed,
                  last_error: "not_modified",
                  finished_at: now(),
                  pages_total: String.to_integer(headers.pages),
                  pages_completed: String.to_integer(headers.pages)
                  }
                )
              :ok


            {:server_error, %Headers{} = _headers, status} ->
              upsert_sync_gen_page(page, generation_id, :retryable, attempt, Integer.to_string(status))


              {:snooze, calc_delay(attempt)}

            {:not_found, body, %Headers{} = headers} ->

              RateLimiter.observe(headers)
              update_generation(generation_id, %{
                  status: :critical,
                  last_error: "not found",
                  finished_at: now(),
                  }
                )
              upsert_sync_gen_page(page, generation_id, :critical, attempt, body)
              :ok

            {:client_error, body, %Headers{} = headers, _status} ->

              RateLimiter.observe(headers)
              update_generation(generation_id, %{
                  status: :critical,
                  last_error: "client error",
                  finished_at: now(),
                  }
                )
              upsert_sync_gen_page(page, generation_id, :critical, attempt, body)
              :ok

              {:unexpected_response, _headers, _status} ->
                upsert_sync_gen_page(page, generation_id, :critical, attempt, :unexpected_response)

                update_generation(generation_id, %{
                  status: :critical,
                  last_error: "unexpected_response",
                  finished_at: now(),
                  }
                )
                # somehow track and report that behavior changed
              :ok
              {:invalid_status, _headers, _status} ->
                upsert_sync_gen_page(page, generation_id, :critical, attempt, :invalid_status)

                update_generation(generation_id, %{
                  status: :critical,
                  last_error: "invalid_status",
                  finished_at: now(),
                  }
                )
              :ok
          end
  end
  def compare_diff(:not_found, _), do: false
  def compare_diff(%{:etag => nil, :expires_at => nil}, _), do: false
  def compare_diff(metadata, now), do: DateTime.compare(metadata.expires_at, now) == :gt
  def prepare_generation(strategy_id, target_id, next_generation) do

    now = DateTime.utc_now() |> DateTime.truncate(:second)
     {:ok, gen} =
        %Sync.EsiSyncGeneration{}
        |> Sync.EsiSyncGeneration.changeset(%{generation: next_generation ,esi_sync_strategy_id: strategy_id, started_at: now, target_id: target_id, status: :running, pages_completed: 0})
        |> Sync.Persistence.insert_generation()
        gen
      end
  def calc_delay(attempt) do
    min(trunc(:math.pow(2, attempt) * 15), 1800)
  end
  def finalize_strategy(strategy, attrs) do
    strategy
    |> EsiSyncStrategy.changeset(attrs)
    |> Sync.Persistence.update_strategy()
  end
  def now() do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
  def calc_next_run(interval_seconds, completion_datetime \\ now()) do
    DateTime.add(completion_datetime, interval_seconds)
  end
  def maybe_get_duration_ms(map, generation) do
    if Map.has_key?(map, :finished_at) do
     Map.put(map, :duration_ms, DateTime.diff(map.finished_at, generation.started_at, :millisecond))
    else
      map
    end
  end

  def advance_page_completed(generation_id, total_pages) do
    Sync.Persistence.increment_generation_pages_completed(generation_id, total_pages)
  end
  def update_generation(generation_id, attrs) do
    generation = Sync.Query.get_generation(generation_id)
    map =
    maybe_get_duration_ms(attrs, generation)




    generation
    |> EsiSyncGeneration.changeset(map)
    |> Sync.Persistence.update_generation()
  end
  defp upsert(body, resource_type, generation, target_id) do
    case resource_type do
      "market_orders" ->
          orders = Enum.map(body, fn order -> MarketOrder.Mapper.from_esi(order, generation, target_id) end)
          MarketOrder.Persistence.upsert_all(orders)
        _->
          :ok
    end

  end
  defp upsert_sync_gen_page(page, esi_sync_generation_id, status, attempt, last_error \\ nil) do
    %Sync.EsiSyncGenerationPage{}
      |> Sync.EsiSyncGenerationPage.changeset(%{page_number: page, esi_sync_generation_id: esi_sync_generation_id, status: status, attempts: attempt, last_error: last_error})
      |> Sync.Persistence.upsert_sync_generation_page()
  end

  defp maybe_update_route_group(resource_name, rate_limit_group) do
    case RouteGroups.get(resource_name) do
      nil ->
        RouteGroups.put(resource_name, rate_limit_group)
      ^rate_limit_group ->
        :ok
      old ->
        Logger.warning(
          "Route group changed for #{resource_name}: #{old} -> #{rate_limit_group}"
        )

        RouteGroups.put(resource_name, rate_limit_group)
    end
  end

end
