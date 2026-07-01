defmodule EveIndustrex.Infrastructure.ESI.Sync.SyncMonitor do
  use GenServer
  require Logger
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def init(_) do
    Logger.info("Starting #{__MODULE__}...")
    :ets.new(:sync_metrics, [:named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:sync_runtime, [:named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:sync_events, [:named_table, :public, read_concurrency: true, write_concurrency: :auto])

    :ets.insert(:sync_metrics, [
      {:generations_completed, 0},
      {:generations_superseeded, 0},
      {:generations_not_modified, 0},
      {:generations_failed, 0},
      {:generations_critical, 0},
      {:duration_count, 0},
      {:duration_total_ms, 0},
      {:pages_completed, 0},
      {:pages_retried, 0},
      {:pages_rate_limited, 0},
    ])

    :telemetry.attach_many("sync-monitor",
      [
        [:eve_industrex, :sync, :generation, :completed],
        [:eve_industrex, :sync, :generation, :superseded],
        [:eve_industrex, :sync, :generation, :not_modified],
        [:eve_industrex, :sync, :generation, :running],
        [:eve_industrex, :sync, :generation, :critical],
        [:eve_industrex, :sync, :generation, :failed],
        [:eve_industrex, :sync, :page, :runtime],
      ],
      &__MODULE__.handle_telemetry/4,
      self()
    )
    {:ok, %{}}
  end

  def handle_telemetry(event, measurements, metadata, pid) do

    send(pid, {:telemetry, event, measurements, metadata})
  end

  def handle_info({:telemetry, [:eve_industrex, :sync, :generation, :running], _measurements, metadata}, state) do

    :ets.insert(:sync_events, {System.unique_integer(), %{
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      event: :generation_started,
      metadata: %{
        resource: metadata.resource,
        strategy_id: metadata.strategy_id,
        target_id: metadata.target_id,
      }
    }})
    {:noreply, state}
  end
  def handle_info({:telemetry, [:eve_industrex, :sync, :generation, :completed], _measurements, metadata}, state) do

    :ets.update_counter(:sync_metrics, :generations_completed, 1, {:generations_completed, 0})

    :ets.insert(:sync_events, {System.unique_integer(), %{
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      event: :generation_completed,
      metadata: %{
        resource: metadata.resource,
        strategy_id: metadata.strategy_id,
      }
    }})
    {:noreply, state}
  end
  def handle_info({:telemetry, [:eve_industrex, :sync, :generation, :superseded], _measurements, metadata}, state) do

    :ets.update_counter(:sync_metrics, :generations_superseded, 1, {:generations_superseded, 0})

    :ets.insert(:sync_events, {System.unique_integer(), %{
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      event: :generation_superseded,
      metadata: %{
        resource: metadata.resource,
        strategy_id: metadata.strategy_id,
        generation_id: metadata.generation_id
      }
    }})
    {:noreply, state}
  end
  def handle_info({:telemetry, [:eve_industrex, :sync, :generation, :not_modified], _measurements, metadata}, state) do

    :ets.update_counter(:sync_metrics, :generations_not_modified, 1, {:generations_not_modified, 0})

    :ets.insert(:sync_events, {System.unique_integer(), %{
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      event: :generation_not_modified,
      metadata: %{
        resource: metadata.resource,
        strategy_id: metadata.strategy_id,
        generation_id: metadata.generation_id
      }
    }})
    {:noreply, state}
  end
  def handle_info({:telemetry, [:eve_industrex, :sync, :generation, :critical], _measurements, metadata}, state) do

    :ets.update_counter(:sync_metrics, :generations_critical, 1, {:generations_critical, 0})

    :ets.insert(:sync_events, {System.unique_integer(), %{
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      event: :generation_critical,
      metadata: %{
        resource: metadata.resource,
        strategy_id: metadata.strategy_id,
        generation_id: metadata.generation_id
      }
    }})
    {:noreply, state}
  end
  def handle_info({:telemetry, [:eve_industrex, :sync, :generation, :failed], _measurements, metadata}, state) do

    :ets.update_counter(:sync_metrics, :generations_failed, 1, {:generations_failed, 0})

    :ets.insert(:sync_events, {System.unique_integer(), %{
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second),
      event: :generation_failed,
      metadata: %{
        resource: metadata.resource,
        strategy_id: metadata.strategy_id,
        generation_id: metadata.generation_id
      }
    }})
    {:noreply, state}
  end

  def handle_info({:telemetry, [:eve_industrex, :sync, :page, :runtime], _measurements, metadata}, state) do
    IO.puts("runtime event")
    :ets.insert(:sync_runtime, {metadata.strategy_id, %{
      generation: metadata.generation,
      page: metadata.page,
      started_at: metadata.started_at,
      pages_total: metadata.pages_total,
      status: metadata.status,
      strategy_id: metadata.strategy_id,
      target_id: metadata.target_id,
    }})

  {:noreply, state}
  end

end
