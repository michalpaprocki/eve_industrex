defmodule EveIndustrex.Schedulers.MarketStatistics do

  alias EveIndustrex.ScheduleOverseer
  require Logger
  use GenServer
  @day 1000 * 60 * 60 * 24
  def init(args) do
    %{:region_id => region_id, :list_of_type_ids => list_of_type_ids} = args
    Logger.info("Starting #{__MODULE__} for region #{region_id}...")
    # Process.send_after(self(), :get_market_statistics, 1000 * 10)
    {:ok, %{:request => :pending, :region_id => region_id, :list_of_type_ids => list_of_type_ids}}
  end
  def start_link(args) do
      %{:region_id => region_id, :list_of_type_ids => _list_of_type_ids} = args
    GenServer.start_link(__MODULE__, args, name: {:via, Registry, {EveIndustrex.Registry, Integer.to_string(region_id)<>"MStats"}})

  end
  def get_state(region_id) do
    GenServer.call({:via, Registry, {EveIndustrex.Registry, Integer.to_string(region_id)<>"MStats"}}, :get_state)
  end
  def initiate_update(region_id) do
    GenServer.call({:via, Registry, {EveIndustrex.Registry, Integer.to_string(region_id)<>"MStats"}}, :init_update)
  end
  def get_pid(region_id) do
    GenServer.call({:via, Registry, {EveIndustrex.Registry, Integer.to_string(region_id)<>"MStats"}}, :get_pid)
  end
   def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:init_update, _from, state) do
      if state.request == :pending do
        send(self(), :get_market_statistics)
      {:reply, "Update initiated...", state}
      else
      {:reply, "Update is queued or underway. Can't initiate.", state}
      end
  end
  def handle_call(:get_pid, _from, state) do
    pid = self()
    {:reply, pid, state}
  end
  def handle_info(:get_market_statistics, state) do
    if state.request == :pending do
      %{:region_id => region_id, :list_of_type_ids => list_of_type_ids} = state
      reply = ScheduleOverseer.get_market_statistics(region_id, list_of_type_ids)
      case reply do
        :postponed ->
          {:noreply, %{:request => reply}}
        :working ->
          {:noreply, %{:request => reply}}
      end
    else
      {:noreply, state}
    end
  end
  def handle_info({:overseer_reply, msg}, _state) do
    case msg do
      :completed ->

          Process.send_after(self(), :get_market_statistics, @day)
        {:noreply, %{:request => :pending}}
      :task_failed ->

        # handle unfinished task
          Process.send_after(self(), :get_market_statistics, @day)
        {:noreply, %{:request => :pending}}
    end
  end
end
