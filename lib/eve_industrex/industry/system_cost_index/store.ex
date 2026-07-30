defmodule EveIndustrex.Industry.SystemCostIndex.Store do
  def get_all() do
    :ets.tab2list(get_system_cost_indices_table())
  end

  def get_activity_system_cost_index(system_id, activity) do
    case :ets.lookup(get_system_cost_indices_table(), {system_id, activity}) do
      [{{^system_id, ^activity}, {cost_index}}] ->
        {system_id, activity, cost_index}

      [] ->
        []
    end
  end

  defp get_system_cost_indices_table() do
    :persistent_term.get(:system_cost_indices_tid)
  end
end
