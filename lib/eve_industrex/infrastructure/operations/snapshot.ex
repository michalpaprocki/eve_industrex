defmodule EveIndustrex.Infrastructure.Operations.Snapshot do
  @moduledoc false
  defstruct [
    :workers,
    :queue,
    :sync,
    :metrics,
    :health,
    :resources,
    :buckets,
    :activity,
    :runtime
  ]
end
