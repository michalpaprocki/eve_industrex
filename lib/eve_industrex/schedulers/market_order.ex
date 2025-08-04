defmodule EveIndustrex.Schedulers.MarketOrder do
  alias EveIndustrex.ScheduleOverseer
  require Logger
  use GenServer
  @hour 1000 * 60 * 60
  def init(init_arg) do
    Logger.info("Starting #{__MODULE__} for region #{init_arg}...")
    Process.send_after(self(), :update_region_orders, 1000 * 10)
    {:ok, %{:request => :pending, :region_id => init_arg}}
  end
  def start_link(arg) do

    GenServer.start_link(__MODULE__, arg, name: {:via, Registry, {EveIndustrex.Registry, arg}})
  end
    def get_state(server) do
    GenServer.call({:via, Registry, {EveIndustrex.Registry, server}}, :get_state)
  end
  def initiate_update(server) do
    GenServer.call({:via, Registry, {EveIndustrex.Registry, server}}, :init_update)
  end
  def get_pid(server) do
    GenServer.call({:via, Registry, {EveIndustrex.Registry, server}}, :get_pid)
  end
   def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:init_update, _from, state) do
    if state.request == :pending do
        send(self(), :update_region_orders)
      {:reply, "Update initiated...", state}
    else
      {:reply, "Update is queued or underway. Can't initiate.", state}
    end
  end
  def handle_call(:get_pid, _from, state) do
    pid = self()
    {:reply, pid, state}
  end
  def handle_info(:update_region_orders, state) do
    if state.request == :pending do
      reply = ScheduleOverseer.update_region_orders(state.region_id)
      case reply do
        :postponed ->
          {:noreply, %{state | :request => reply}}
        :working ->
          {:noreply, %{state | :request => reply}}
      end
    else
      {:noreply, state}
    end
  end
  def handle_info({:overseer_reply, msg}, state) do

    case msg do
      :completed ->
          Process.send_after(self(), :update_region_orders, @hour)
        {:noreply, %{state |:request => :pending}}
      :task_failed ->
        # handle unfinished task
        {:noreply, %{state |:request => :pending}}
    end
  end
end
