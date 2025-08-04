defmodule EveIndustrex.ScheduleOverseer do
  require Logger
  alias EveIndustrex.Logger.EiLogger
  alias EveIndustrex.Utils

  alias EveIndustrex.Tasks.Update
  alias EveIndustrex.Generic

  alias EveIndustrex.Tasks.CheckTqVersion
  use GenServer
  def init(_init_arg) do
    Logger.info("Starting #{__MODULE__}...")

    {:ok, %{:is_working? => false, :reserved_by => [], :client => nil}}
  end
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end
  def update_region_orders(region_id) do
    GenServer.call(__MODULE__, {:update_region_orders, region_id})
  end
  def check_tq_version() do
    GenServer.call(__MODULE__, :check_tq_version)
  end
  def update_average_prices() do
    GenServer.call(__MODULE__, :update_average_prices)
  end
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end
  def handle_call(:get_state, _from, state) do
    reserved_length = length(state.reserved_by)

    {:reply, %{:state => state, :queue_length => reserved_length}, state}
  end
  def handle_call({:update_region_orders, region_id}, from, state) do
    %{:is_working? => is_working?, :reserved_by => reserved_by} = state
    if is_working? == false do
      task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :market_orders, [region_id])
      {:reply, :working, %{state | :is_working? => true, :client => %{:pid => elem(from, 0), :ref => task.ref}}}
    else
      new_reserved_by = [%{:pid => elem(from, 0), :call => :update_market_orders, :arg => region_id} | Enum.reverse(reserved_by)] |> Enum.reverse()
      {:reply, :postponed, %{state | :reserved_by => new_reserved_by}}
    end
  end

  def handle_call(:check_tq_version, from, state) do
    %{:is_working? => is_working?, :reserved_by => reserved_by} = state
    if is_working? == false do
      task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, CheckTqVersion, :check_latest_game_version, [])
      {:reply, :working, %{state | :is_working? => true, :client => %{:pid => elem(from, 0), :ref => task.ref}}}
    else
      new_reserved_by = [%{:pid => elem(from, 0), :call => :check_tq_version,  :arg => nil} | Enum.reverse(reserved_by)] |> Enum.reverse()
      {:reply, :postponed, %{state | :reserved_by => new_reserved_by}}
    end
  end
  def handle_call(:update_average_prices, from, state) do
    %{:is_working? => is_working?, :reserved_by => reserved_by} = state
    if is_working? == false do

      task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :average_prices, [])
      {:reply, :working, %{state | :is_working? => true, :client => %{:pid => elem(from, 0), :ref => task.ref}}}
    else
      new_reserved_by = [%{:pid => elem(from, 0), :call => :update_average_prices,  :arg => nil} | Enum.reverse(reserved_by)] |> Enum.reverse()
      {:reply, :postponed, %{state | :reserved_by => new_reserved_by}}
    end
  end
  def handle_info({:reserved, %{:pid => pid, :call => call, :arg => arg}}, state) do
    case call do
      :update_market_orders ->
        task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :market_orders, [arg])
        {:noreply, %{state | :client => %{:pid => pid, :ref => task.ref}}}
      :check_tq_version ->
        task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, CheckTqVersion, :check_latest_game_version, [])
        {:noreply, %{state | :client => %{:pid => pid, :ref => task.ref}}}
      :update_average_prices ->
        task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :average_prices, [])
        {:noreply, %{state | :client => %{:pid => pid, :ref => task.ref}}}
    end
  end

  def handle_info({ref, answer}, state) do

    Process.demonitor(ref, [:flush])
    %{:reserved_by => reserved_by, :client => client} = state

    case answer do
      :ok ->
        send(client.pid, {:overseer_reply, :completed})
        if length(reserved_by) > 0 do
          send(self(), {:reserved, hd(reserved_by)})
          {:noreply, %{state | :reserved_by => tl(reserved_by)}}
        else
          {:noreply, %{state | :is_working? => false, :client => nil}}
        end
      :noop ->
        send(client.pid, {:overseer_reply, :completed})
        if length(reserved_by) > 0 do
          send(self(), {:reserved, hd(reserved_by)})
          {:noreply, %{state | :reserved_by => tl(reserved_by)}}
        else
          {:noreply, %{state | :is_working? => false, :client => nil}}
        end

      {:update, tq_version} ->
        Generic.upsert_tq_version(tq_version)
        send(client.pid, {:overseer_reply, :completed})
        if length(reserved_by) > 0 do
          send(self(), {:reserved, hd(reserved_by)})
          {:noreply, %{state | :reserved_by => tl(reserved_by)}}
        else
          {:noreply, %{state | :is_working? => false, :client => nil}}
        end

      {:run_SDE_update, tq_version} ->
        task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :from_SDE, [tq_version])
        send(client.pid, {:overseer_reply, :completed})
        {:noreply, %{state | :client => %{:pid => client.pid, :ref => task.ref}}}

      {:run_html_parser, _tq_version} ->
        send(client.pid, {:overseer_reply, :completed})
        # WIP
        {:noreply, %{state | :is_working? => false, :client => nil}}

      {error, reason, url} ->
        send(client.pid, {:overseer_reply, :task_failed})
        EiLogger.log(:error, {error, reason, url})
        {:noreply, %{state | :is_working? => false, :client => nil}}

      end
  end
  def handle_info({:DOWN, _ref, _process, _pid, :normal}, state) do
    # runs on task completion - can be ignored
    {:noreply, state}
  end
  def handle_info({:DOWN, _ref, _process, _pid, reason} = _msg, state, state) do
    %{:client => client} = state
    # runs on task fail
    # log and notify about err, que next check
    send(client.pid, {:overseer_reply, :task_failed})
    EiLogger.log(:error, {:task_failed, reason, get_module_mame()})
    {:noreply, %{state | :is_working? => false, :client => nil}}
  end
  defp get_module_mame(), do: Atom.to_string(__MODULE__)
end
