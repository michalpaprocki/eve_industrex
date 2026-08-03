defmodule EveIndustrex.Infrastructure.Operations.Service do
  alias EveIndustrex.Infrastructure.Operations.Activity
  alias EveIndustrex.Infrastructure.Operations.Metrics
  alias EveIndustrex.Infrastructure.Operations.Snapshot
  alias EveIndustrex.Infrastructure.ESI
  @moduledoc false
  def snapshot() do
    %Snapshot{
      resources: get_resources(),
      buckets: get_buckets(),
      metrics: Metrics.get_metrics(),
      activity: Activity.get_activities() |> Enum.sort_by(& &1.timestamp, :desc)
    }
  end

  defp get_resources() do
    Activity.get_activities()
    |> Enum.filter(fn a -> a.activity == :projection_rebuilt end)
    |> Enum.sort_by(& &1.timestamp, :desc)
    |> Enum.uniq_by(& &1.resource)
  end

  defp get_buckets() do
    ESI.RateLimiter.check()
  end
end
