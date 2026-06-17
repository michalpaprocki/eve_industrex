defmodule EveIndustrex.Infrastructure.ESI.RouteGroups do
  use GenServer
  require Logger
  def init(_init_arg) do
    Logger.info("Starting #{__MODULE__}...")
    :ets.new(:esi_route_groups, [:bag, :protected, :named_table, read_concurrency: true])
    {:ok, %{}}
  end
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def put(resource_type, rate_limit_group) do
    GenServer.cast(__MODULE__, {:put, resource_type, rate_limit_group})
  end
  def get(resource_type) do
    GenServer.call(__MODULE__, {:get, resource_type})
  end

  def handle_cast({:put, resource_type, rate_limit_group}, state) do
    :ets.insert(:esi_route_groups, {resource_type, rate_limit_group})
    {:noreply, state}
  end
  def handle_call({:get, resource_type}, _from, state) do
    resp =
    case :ets.lookup(:esi_route_groups, resource_type) do
      [] ->
        :ok
      [{_key, rate_limit_group}] ->
        rate_limit_group
    end
    {:reply, resp , state}
  end
end
