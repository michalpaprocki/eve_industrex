defmodule EveIndustrex.Infrastructure.Operations.Metrics do
  defstruct [
    :duration_count,
    :duration_total_ms,
    :generations_completed,
    :generations_critical,
    :generations_failed,
    :generations_not_modified,
    :generations_running,
    :generations_started,
    :generations_superseded,
    :pages_completed,
    :pages_rate_limited,
    :pages_retried,
    :groups_imported,
    :types_imported,
    :categories_imported,
    :market_groups_imported
  ]

  def get_metrics() do
    metrics = :ets.tab2list(:sync_metrics) |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))

    struct(
      __MODULE__,
      Map.new(metrics, fn {k, v} ->
        {k, v}
      end)
    )
  end
end
