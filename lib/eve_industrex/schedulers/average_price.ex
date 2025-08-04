defmodule EveIndustrex.Schedulers.AveragePrice do
  alias EveIndustrex.ScheduleOverseer
  require Logger
  use GenServer
  @day 1000 * 60 * 60 * 24
  def init(_init_arg) do
    Logger.info("Starting #{__MODULE__}...")
    Process.send_after(self(), :update_average_prices, @day)
    {:ok, %{:request => :pending}}
  end
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end
  def get_pid() do
    GenServer.call(__MODULE__, :get_pid)
  end
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end
  def initiate_update() do
    GenServer.call(__MODULE__, :init_update)
  end
   def handle_call(:get_pid, _from, state) do
    pid = self()
    {:reply, pid, state}
  end
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:init_update, _from, state) do
    if state.request == :pending do
      send(self(), :update_average_prices)
      {:reply, "Update initiated...", state}
    else
      {:reply, "Update is queued or underway. Can't initiate.", state}
    end
  end
  def handle_info(:update_average_prices, state) do
    if state.request == :pending do
      reply = ScheduleOverseer.update_average_prices()
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
        IO.puts("task completed")
        Process.send_after(self(), :update_average_prices, @day)
        {:noreply, %{:request => :pending}}
      :task_failed ->
        # handle unfinished task
        {:noreply, %{:request => :pending}}
    end
  end
end
