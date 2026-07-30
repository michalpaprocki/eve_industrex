defmodule EveIndustrex.Infrastructure.ESI.Sync.SyncProvider do
  def default_strategy(target_id, resource) do
    case resource.name do
      "market_orders" ->
        %{
          resource_type_id: resource.id,
          target_id: target_id,
          sync_interval_seconds: 3600,
          last_successful_sync: nil,
          enabled: true,
          next_generation: 1,
          status: :idle,
          next_run_at: DateTime.utc_now() |> DateTime.truncate(:second)
        }

      "average_prices" ->
        %{
          resource_type_id: resource.id,
          target_id: nil,
          sync_interval_seconds: 86400,
          last_successful_sync: nil,
          enabled: true,
          next_generation: 1,
          status: :idle,
          next_run_at: DateTime.utc_now() |> DateTime.truncate(:second)
        }

      "system_cost_indices" ->
        %{
          resource_type_id: resource.id,
          target_id: nil,
          sync_interval_seconds: 3600,
          last_successful_sync: nil,
          enabled: true,
          next_generation: 1,
          status: :idle,
          next_run_at: DateTime.utc_now() |> DateTime.truncate(:second)
        }

      _ ->
        %{
          resource_type_id: resource.id,
          target_id: target_id,
          sync_interval_seconds: 3600,
          last_successful_sync: nil,
          enabled: true,
          next_generation: 1,
          status: :idle,
          next_run_at: DateTime.utc_now() |> DateTime.truncate(:second)
        }
    end
  end
end
