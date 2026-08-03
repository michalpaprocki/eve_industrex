defmodule EveIndustrex.Infrastructure.Operations.Activity do
  defstruct [:activity, :timestamp, :resource, :group, :route, :count]
  @moduledoc false
  def get_activities() do
    activities = :ets.tab2list(:sync_activities) |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))

    Enum.map(activities, fn {_id, a} ->
      struct(
        __MODULE__,
        Map.new(a, fn {k, v} ->
          {k, v}
        end)
      )
    end)
  end
end
