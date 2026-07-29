defmodule EveIndustrex.Infrastructure.Operations.Snapshot do
  defstruct [:workers, :queue, :sync, :metrics, :health, :resources, :buckets, :activity, :runtime]
end
