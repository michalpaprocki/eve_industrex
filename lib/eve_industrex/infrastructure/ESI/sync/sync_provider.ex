defmodule EveIndustrex.Infrastructure.ESI.Sync.SyncProvider do

  def default_market_order_strategy(target_id, resource_type_id) do
    %{
      resource_type_id: resource_type_id,
      target_id: target_id,
      sync_interval_seconds: 3600,
      last_successful_sync: nil,
      enabled: true
    }
  end
end
