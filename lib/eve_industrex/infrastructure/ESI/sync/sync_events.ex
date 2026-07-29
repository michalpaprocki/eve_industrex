defmodule EveIndustrex.Infrastructure.ESI.Sync.SyncEvents do

require Logger
  def generation_running(generation, strategy) do
      :telemetry.execute(
      [:eve_industrex, :sync, :generation, :running],
      %{duration_ms: generation.duration_ms},
      %{
        generation_id: generation.id,
        strategy_id: strategy.id,
        resource: strategy.resource_type.name,
        target_id: generation.target_id,
        status: strategy.status,
        generation: generation.generation,
        last_error: generation.last_error,
        started_at: generation.started_at,
        finished_at: generation.finished_at,
      }
    )
  end
  def generation_completed(generation, strategy) do
    :telemetry.execute(
      [:eve_industrex, :sync, :generation, :completed],
      %{duration_ms: generation.duration_ms},
      %{
        generation_id: generation.id,
        strategy_id: strategy.id,
        resource: strategy.resource_type.name,
        target_id: generation.target_id,
        status: strategy.status,
        generation: generation.generation,
        last_error: generation.last_error,
        started_at: generation.started_at,
        finished_at: generation.finished_at,
      }
    )

  end
  def generation_superseded(generation, strategy) do
      :telemetry.execute(
      [:eve_industrex, :sync, :generation, :superseded],
      %{duration_ms: generation.duration_ms},
      %{
        generation_id: generation.id,
        strategy_id: strategy.id,
        resource: strategy.resource_type.name,
        target_id: generation.target_id,
        status: strategy.status,
        generation: generation.generation,
        last_error: generation.last_error,
        started_at: generation.started_at,
        finished_at: generation.finished_at,
      }
    )
  end
  def generation_not_modified(generation, strategy) do
      :telemetry.execute(
      [:eve_industrex, :sync, :generation, :not_modified],
      %{duration_ms: generation.duration_ms},
      %{
        generation_id: generation.id,
        strategy_id: strategy.id,
        resource: strategy.resource_type.name,
        target_id: generation.target_id,
        status: strategy.status,
        generation: generation.generation,
        last_error: generation.last_error,
        started_at: generation.started_at,
        finished_at: generation.finished_at,
      }
    )
  end
  def generation_critical(generation, strategy) do
      :telemetry.execute(
      [:eve_industrex, :sync, :generation, :critical],
      %{duration_ms: generation.duration_ms},
      %{
        generation_id: generation.id,
        strategy_id: strategy.id,
        resource: strategy.resource_type.name,
        target_id: generation.target_id,
        status: strategy.status,
        generation: generation.generation,
        last_error: generation.last_error,
        started_at: generation.started_at,
        finished_at: generation.finished_at,
      }
    )
  end

  def generation_failed(generation, strategy) do
      :telemetry.execute(
      [:eve_industrex, :sync, :generation, :failed],
      %{duration_ms: generation.duration_ms},
      %{
        generation_id: generation.id,
        strategy_id: strategy.id,
        resource: strategy.resource_type.name,
        target_id: generation.target_id,
        status: strategy.status,
        generation: generation.generation,
        last_error: generation.last_error,
        started_at: generation.started_at,
        finished_at: generation.finished_at,
      }
    )
  end
  def runtime(status, generation, page) do
    :telemetry.execute(
      [:eve_industrex, :sync, :page, :runtime],
      %{},
      %{
        status: status,
        generation: generation.generation,
        strategy_id: generation.esi_sync_strategy_id,
        started_at: generation.started_at,
        target_id: generation.target_id,
        page: page,
        pages_total: generation.pages_total
      }
    )
  end
  def dependencies_imported(0, _type) do
    :noop
  end
  def dependencies_imported(amount, type) do
    :telemetry.execute(
      [:eve_industrex, :universe, :dependencies],
      %{count: amount},
      %{entity: type}
    )
  end
  def sync_started(resource) do
    :telemetry.execute(
      [:eve_industrex, :activity, :sync_started],
      %{},
      %{resource: resource}
    )
  end
  def sync_finished(resource) do
    :telemetry.execute(
      [:eve_industrex, :activity, :sync_finished],
      %{},
      %{resource: resource}
    )
  end
  def rate_limit_discovered(group, route) do
    :telemetry.execute(
      [:eve_industrex, :activity, :rate_limit_group_discovered],
      %{},
      %{
        group: group,
        route: route
      }
    )
  end
  def projection_rebuilt(resource) do
    :telemetry.execute(
      [:eve_industrex, :activity, :projection_rebuilt],
      %{},
      %{
        resource: resource
      }
    )
  end
end
