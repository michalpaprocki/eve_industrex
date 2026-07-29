defmodule EveIndustrex.Infrastructure.Operations.Events do

  def get_events() do
    :ets.tab2list(:sync_events)
  end
end
