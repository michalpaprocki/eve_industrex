defmodule EveIndustrex.Infrastructure.ESI.Sync.OrchestratorService do
  require Logger
  alias EveIndustrex.Infrastructure.ESI.Sync.Universe
  alias EveIndustrex.Industry.SystemCostIndex
  alias EveIndustrex.Infrastructure.ESI.Sync.SyncEvents
  alias EveIndustrex.Infrastructure.ESI.ClientHandler
  alias EveIndustrex.Infrastructure.ESI.Headers
  alias EveIndustrex.Infrastructure.ESI.Sync.{EsiSyncGeneration, EsiSyncStrategy}
  alias EveIndustrex.Infrastructure.ESI.Sync
  alias EveIndustrex.Market.{AveragePrice, MarketOrder}
  alias EveIndustrex.Infrastructure.ESI.RouteGroups
  alias EveIndustrex.Infrastructure.ESI.RateLimiter

  def orchestrate(
        fetch_fn,
        generation_id,
        generation,
        attempt,
        max_attempts,
        strategy,
        metadata,
        page \\ 1
      ) do
    gen = Sync.Query.get_generation(generation_id)

    if gen.status != :running do
      :ok
    else
      case ClientHandler.handle_response(fetch_fn.(strategy.target_id, page, metadata)) do
        {:success, body, %Headers{} = headers} ->
          snapshot_last_modified =
            DateTimeParser.parse_datetime!(headers.last_modified, to_utc: true)
            |> DateTime.from_naive!("Etc/UTC")
            |> DateTime.truncate(:second)

          {:ok, gen} =
            if page == 1 do
              snapshot_expires_at =
                DateTimeParser.parse_datetime!(headers.expires_at, to_utc: true)
                |> DateTime.from_naive!("Etc/UTC")
                |> DateTime.truncate(:second)

              maybe_update_route_group(strategy.resource_type.name, headers.rate_limit_group)

              update_generation(generation_id, %{
                snapshot_etag: headers.etag,
                snapshot_expires_at: snapshot_expires_at,
                snapshot_last_modified: snapshot_last_modified,
                last_error: "",
                pages_total: maybe_insert_pages_total(headers)
              })
            else
              {:ok, gen}
            end

          RateLimiter.observe(headers)

          if snapshot_last_modified == gen.snapshot_last_modified do
            if not is_nil(headers.pages) do
              upsert_sync_gen_page(page, generation_id, :completed, attempt)
              advance_page_completed(generation_id, String.to_integer(headers.pages))
            end

            case upsert(body, strategy.resource_type.name, generation, strategy.target_id) do
              :ok ->
                SyncEvents.runtime(:completed, gen, page)

                cond do
                  (not is_nil(headers.pages) and String.to_integer(headers.pages) > 1) &&
                      page == 1 ->
                    {:fanout, String.to_integer(headers.pages)}

                  is_nil(headers.pages) and page == 1 ->
                    :ok

                  page == 1 ->
                    {:ok, String.to_integer(headers.pages), generation_id}

                  true ->
                    :ok
                end

              {:error, _error} ->
                # deps not updated - fail gen
                {:ok, _gen} =
                  update_generation(generation_id, %{
                    status: :failed,
                    last_error: "deps not updated",
                    finished_at: now(),
                    pages_total: maybe_insert_pages_total(headers),
                    pages_completed: 0
                  })

                :ok
            end
          else
            # mark as superseded and restart
            {:ok, gen} =
              update_generation(generation_id, %{
                status: :superseded,
                last_error: "last_modified_missmatch",
                finished_at: now(),
                pages_total: String.to_integer(headers.pages)
              })

            SyncEvents.runtime(:superseded, gen, page)
            :ok
          end

        {:rate_limited, %Headers{} = headers} ->
          if not is_nil(headers.pages) do
            upsert_sync_gen_page(
              page,
              generation_id,
              :rate_limited,
              attempt,
              "page rate limited " <> Integer.to_string(attempt) <> " times"
            )
          end

          RateLimiter.cooldown(headers)

          if attempt >= max_attempts do
            {:ok, gen} =
              update_generation(generation_id, %{
                status: :failed,
                last_error: "max_attempts_exceeded: rate limited",
                finished_at: now(),
                pages_total: maybe_insert_pages_total(headers),
                pages_completed: 0
              })

            SyncEvents.runtime(:rate_limited, gen, page)

            :ok
          else
            {:snooze, calc_delay(attempt)}
          end

        {:not_modified, %Headers{} = headers} ->
          snapshot_last_modified =
            DateTimeParser.parse_datetime!(headers.last_modified, to_utc: true)
            |> DateTime.from_naive!("Etc/UTC")
            |> DateTime.truncate(:second)

          snapshot_expires_at =
            DateTimeParser.parse_datetime!(headers.expires_at, to_utc: true)
            |> DateTime.from_naive!("Etc/UTC")
            |> DateTime.truncate(:second)

          upsert_sync_gen_page(page, generation_id, :matched, attempt)

          {:ok, gen} =
            update_generation(generation_id, %{
              status: :not_modified,
              last_error: nil,
              snapshot_etag: headers.etag,
              snapshot_expires_at: snapshot_expires_at,
              snapshot_last_modified: snapshot_last_modified,
              finished_at: now(),
              pages_total: maybe_insert_pages_total(headers),
              pages_completed: 0
            })

          SyncEvents.runtime(:not_modified, gen, page)
          RateLimiter.observe(headers)

          :ok

        {:server_error, %Headers{} = _headers, status} ->
          upsert_sync_gen_page(
            page,
            generation_id,
            :retryable,
            attempt,
            Integer.to_string(status)
          )

          #  RateLimiter.observe(headers)
          Logger.warning("Server error, snoozing job.")
          SyncEvents.runtime(:server_error, gen, page)
          {:snooze, calc_delay(attempt)}

        {:not_found, _body, %Headers{} = headers, status} ->
          RateLimiter.observe(headers)
          upsert_sync_gen_page(page, generation_id, :critical, attempt, Integer.to_string(status))

          {:ok, gen} =
            update_generation(generation_id, %{
              status: :critical,
              last_error: "not found",
              finished_at: now()
            })

          SyncEvents.runtime(:critical, gen, page)

          :ok

        {:client_error, _body, %Headers{} = headers, status} ->
          RateLimiter.observe(headers)
          upsert_sync_gen_page(page, generation_id, :critical, attempt, Integer.to_string(status))

          {:ok, gen} =
            update_generation(generation_id, %{
              status: :critical,
              last_error: "client error",
              finished_at: now()
            })

          SyncEvents.runtime(:critical, gen, page)
          :ok

        {:unexpected_response, headers, status} ->
          if not is_nil(headers.pages) do
            upsert_sync_gen_page(
              page,
              generation_id,
              :critical,
              attempt,
              Integer.to_string(status)
            )
          end

          RateLimiter.observe(headers)

          {:ok, gen} =
            update_generation(generation_id, %{
              status: :critical,
              last_error: "unexpected_response",
              finished_at: now()
            })

          # somehow track and report that behavior changed
          SyncEvents.runtime(:unexpected_response, gen, page)
          :ok

        {:invalid_status, headers, status} ->
          RateLimiter.observe(headers)

          if not is_nil(headers.pages) do
            upsert_sync_gen_page(
              page,
              generation_id,
              :critical,
              attempt,
              Integer.to_string(status)
            )
          end

          {:ok, gen} =
            update_generation(generation_id, %{
              status: :critical,
              last_error: "invalid_status - #{status}",
              finished_at: now()
            })

          SyncEvents.runtime(:invalid_status, gen, page)
          :ok
      end
    end
  end

  def prepare_generation(strategy) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    {:ok, gen} =
      %Sync.EsiSyncGeneration{}
      |> Sync.EsiSyncGeneration.changeset(%{
        generation: strategy.next_generation,
        esi_sync_strategy_id: strategy.id,
        started_at: now,
        target_id: strategy.target_id,
        status: :running,
        pages_completed: 0
      })
      |> Sync.Persistence.insert_generation()

    SyncEvents.generation_running(gen, strategy)
    gen
  end

  def delete_superseded_gen(gen_id) do
    Sync.Persistence.delete_generation(gen_id)
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
    if Map.has_key?(map, :finished_at) and Map.has_key?(generation, :started_at) do
      Map.put(
        map,
        :duration_ms,
        DateTime.diff(map.finished_at, generation.started_at, :millisecond)
      )
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

  def mark_orders_as_new_gen(target_id, generation) do
    MarketOrder.Persistence.update_orders_generation(target_id, generation)
  end

  # possibly pass a ready function into the orchestrate fn instead of matching here
  defp upsert(body, resource_type, generation, target_id) do
    case resource_type do
      "market_orders" ->
        orders =
          Enum.map(body, fn order -> MarketOrder.Mapper.from_esi(order, generation, target_id) end)

        type_ids =
          Enum.map(orders, fn mo ->
            mo.type_id
          end)
          |> Enum.uniq()

        case Universe.ensure_type_dependencies(type_ids) do
          {categories, groups, market_groups, types} ->
            Universe.update_caches({categories, groups, market_groups, types})
            MarketOrder.Persistence.upsert_all(orders)
            :ok

          {:error, error} ->
            {:error, error}
        end

      "average_prices" ->
        average_prices = Enum.map(body, fn ap -> AveragePrice.Mapper.from_esi(ap) end)

        type_ids =
          Enum.map(average_prices, fn ap ->
            ap.type_id
          end)
          |> Enum.uniq()

        case Universe.ensure_type_dependencies(type_ids) do
          {categories, groups, market_groups, types} ->
            Universe.update_caches({categories, groups, market_groups, types})
            chunks = Enum.chunk_every(average_prices, 5000)
            Enum.each(chunks, fn chunk -> AveragePrice.Persistence.upsert_all(chunk) end)
            :ok

          err ->
            err
        end

      "system_cost_indices" ->
        system_cost_indices =
          Enum.map(body, fn sci ->
            SystemCostIndex.Mapper.from_esi(sci)
          end)
          |> List.flatten()
          |> Enum.chunk_every(5000)

        Enum.each(system_cost_indices, fn chunk ->
          SystemCostIndex.Persistence.upsert_all(chunk)
        end)

        :ok

      _ ->
        :ok
    end
  end

  defp upsert_sync_gen_page(page, esi_sync_generation_id, status, attempt, last_error \\ nil) do
    %Sync.EsiSyncGenerationPage{}
    |> Sync.EsiSyncGenerationPage.changeset(%{
      page_number: page,
      esi_sync_generation_id: esi_sync_generation_id,
      status: status,
      attempts: attempt,
      last_error: last_error
    })
    |> Sync.Persistence.upsert_sync_generation_page()
  end

  defp maybe_update_route_group(resource_name, nil) do
    case RouteGroups.get(resource_name) do
      "global" ->
        :ok

      :ok ->
        Logger.warning("Added #{resource_name} to global rate limit group")
        SyncEvents.rate_limit_discovered(resource_name, "global")
        RouteGroups.put(resource_name, "global")
    end
  end

  defp maybe_update_route_group(resource_name, rate_limit_group) do
    case RouteGroups.get(resource_name) do
      ^rate_limit_group ->
        :ok

      old ->
        Logger.warning("Route group changed for #{resource_name}: #{old} -> #{rate_limit_group}")
        SyncEvents.rate_limit_discovered(resource_name, rate_limit_group)
        RouteGroups.put(resource_name, rate_limit_group)
    end
  end

  defp maybe_insert_pages_total(headers) do
    if(not is_nil(headers.pages), do: String.to_integer(headers.pages), else: nil)
  end
end
