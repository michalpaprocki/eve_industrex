
defmodule EveIndustrex.ScheduleOverseer do
  defmodule Client do
  @moduledoc false
  defstruct [
    :id,
    :pid,
    :ref,
    :call,
    :arg,
    :chunks,
    :chunk_size,
    :called,
    :fun
  ]
  end
  require Logger
  alias __MODULE__.Client
  alias EveIndustrex.RoutesStatus
  alias EveIndustrex.Logger.EiLogger
  alias EveIndustrex.Utils
  alias EveIndustrex.Tasks.Update
  alias EveIndustrex.Generic
  alias EveIndustrex.Tasks.CheckTqVersion
  use GenServer

  @routes_of_interest %{
    :average_prices => %{
      "endpoint" => "esi-markets",
      "method" => "get",
      "route" => "/markets/prices/",
      "status" => nil,
      "tags" => ["Market"]
    },
    :market_orders => %{
      "endpoint" => "esi-markets",
      "method" => "get",
      "route" => "/markets/{region_id}/orders/",
      "status" => nil,
      "tags" => ["Market"]
    },
    :market_statistics => %{
      "endpoint" => "esi-markets",
      "method" => "get",
      "route" => "/markets/{region_id}/history/",
      "status" => nil,
      "tags" => ["Market"]
    }
  }

  def init(_init_arg) do
    Logger.info("Starting #{__MODULE__}...")
    status =
    case RoutesStatus.check_routes_status(@routes_of_interest) do
      {:error, error} ->
        EiLogger.log(:error, error)
        nil
      {status, _last_modified, _expiries} ->
        status
      end
      {:ok, %{:is_working? => false, :reserved_by => [], :client => nil, :routes_info => status, :check_initiated? => false}}
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
  def get_market_statistics(region_id, list_of_type_ids) do
    GenServer.call(__MODULE__, {:market_statistics, region_id, list_of_type_ids})
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
  #  def handle_call({:get_market_statistics, region_id, list_of_type_ids}, from, state) do
  #   %{:is_working? => is_working?, :reserved_by => reserved_by} = state
  #   if is_working? == false do
  #     chunks = Enum.chunk_every(list_of_type_ids, 1000)
  #     Logger.info("Started fething data for #{inspect(length(hd(chunks)))} entries... | #{inspect(length(Enum.drop(chunks, 1)))} sets left...")
  #     task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :market_statistics, [region_id, hd(chunks)])
  #     {:reply, :working, %{state | :is_working? => true, :client => %{:pid => elem(from, 0), :ref => task.ref, :chunks => Enum.drop(chunks, 1), :called => DateTime.now!("Etc/UTC"), :arg => {region_id, list_of_type_ids}, :call => :get_market_statistics}}}
  #   else
  #     new_reserved_by = [%{:pid => elem(from, 0), :call => :get_market_statistics, :arg => {region_id, list_of_type_ids}} | Enum.reverse(reserved_by)] |> Enum.reverse()
  #     {:reply, :postponed, %{state | :reserved_by => new_reserved_by}}
  #   end
  # end
  def handle_call({:market_statistics, region_id, list_of_type_ids}, from, state) do
      task_fun = fn {region_id, chunk} -> Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :market_statistics, [region_id, chunk]) end
      maybe_start_chunked_task(state, from, :market_statistics, list_of_type_ids, 1, task_fun, region_id)
  end
  def handle_call({:update_region_orders, region_id}, from, state) do
      task_fun = fn region_id -> Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :market_orders, [region_id]) end
      maybe_start_task_with_arg(state, from, :market_orders, task_fun, region_id)
  end
  def handle_call(:check_tq_version, from, state) do
      task_fun = fn -> Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, CheckTqVersion, :check_latest_game_version, []) end
      maybe_start_task(state, from, :check_tq_version, task_fun)
  end
  def handle_call(:update_average_prices, from, state) do
      task_fun = fn ->  Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :average_prices, []) end
      maybe_start_task(state, from, :average_prices, task_fun)
  end
  def handle_info({:add_to_reserved, client}, state) do

    %{:reserved_by => reserved_by} = state

    {:noreply, %{state | :reserved_by => [client | reserved_by]}}
  end
  def handle_info({:handle_reserved}, state) do
    IO.puts("received :handle_reserved")
    %{:reserved_by => reserved_by} = state
    IO.inspect(reserved_by)
   %{:call => call} = hd(reserved_by)
    # IO.puts("Stating reserved action for #{inspect(caller.pid)}, #{inspect(caller.call)}, #{caller.arg}")

    case call do
      :market_orders ->
        handle_market_call(state)
      :check_tq_version ->
        handle_version_call(state)
      :update_average_prices ->
        handle_prices_call(state)
      :market_statistics ->
        handle_statistics_call(state)
      true ->
        {:noreply, state}
    end
  end
  def handle_info({:check_routes_status, call}, state) do
    if call == :instant && state.check_initiated? == true do
      {:noreply, state}
     else

    case RoutesStatus.check_routes_status(@routes_of_interest) do
      {:error, error} ->
        EiLogger.log(:error, error)
        Process.send_after(self(), {:check_routes_status, :scheduled}, 1000 * 60 * 5)
        {:noreply, %{state | :check_initiated? => true}}
      {status, _last_modified, _expiries} ->
        routes_statuses = Enum.map(Map.values(status), fn x -> Enum.member?(Map.values(x), "green") end)
        if Enum.member?(routes_statuses, false) do
          Process.send_after(self(), {:check_routes_status, :scheduled}, 1000 * 60 * 5)
          state_with_status = %{state | :routes_info => status}
          {:noreply, %{state_with_status | :check_initiated? => true}}
        else
          cond do
            length(state.reserved_by) > 0 ->
              Process.send_after(self(), {:handle_reserved}, 2000)
            true ->
              :noop
          end
           state_with_status = %{state | :routes_info => status}
          {:noreply, %{state_with_status | :check_initiated? => false}}
        end
      end
    end
  end
  def handle_info({ref, answer}, %{:client => %Client{} = client} = state) do
    IO.puts("Task Complete")
    Process.demonitor(ref, [:flush])
    %{:reserved_by => reserved_by} = state
    case answer do
      :ok ->
        IO.inspect(client)
        # start here
        if Map.has_key?(client, :chunks) and is_nil(client.chunks) do
          IO.puts("completed, sending reply from overseer")
          send(client.pid, {:overseer_reply, :completed})
        end
        if Map.has_key?(client, :chunks) and Map.has_key?(client, :called) and !is_nil(client.chunks) and length(client.chunks) > 0 do

          if length(state.reserved_by) > 0 and !Enum.find(state.reserved_by, fn r -> r.id == client.id end) do
            Process.send_after(self(), {:add_to_reserved, client}, 0)
          end
          Process.send_after(self(), {:handle_reserved}, 8000)
          {:noreply, state}
        else

          IO.puts("no more chunks, removing client: #{inspect(client)} from reserved, if length of reserved is > 0, sending :handle_reserved in 2secs, else setting state to default")

          if length(reserved_by) > 0 do
            IO.puts("starting next in the queue")
            Process.send_after(self(), {:handle_reserved}, 2000)
            new_state = %{state | :client => nil}
            {:noreply, new_state}
          else
            {:noreply, %{state | :is_working? => false, :client => nil, :reserved_by => []}}
          end
        end

      :noop ->
        send(client.pid, {:overseer_reply, :completed})
        if length(reserved_by) > 0 do
          Process.send_after(self(), {:handle_reserved}, 2000)
          {:noreply, state}
        else
          {:noreply, %{state | :is_working? => false, :client => nil}}
        end

      {:update, tq_version} ->
        Generic.upsert_tq_version(tq_version)
        send(client.pid, {:overseer_reply, :completed})
        if length(reserved_by) > 0 do
            Process.send_after(self(), {:handle_reserved}, 2000)
          {:noreply, state}
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

      {:error, {error, reason, url}} ->
        send(client.pid, {:overseer_reply, :task_failed})
        EiLogger.log(:error, {error, reason, url})
        cond do
          reason == :err_responded_with ->
            send(self(), {:check_routes_status, :instant})
            {:noreply, %{state | :is_working? => true, :client => :self}}
          length(reserved_by) > 0 ->
            Process.send_after(self(), {:handle_reserved}, 2000)
            {:noreply, state}
          true ->
            {:noreply, %{state | :is_working? => false, :client => nil}}
        end
      end
  end
  def handle_info({:DOWN, _ref, _process, _pid, :normal}, state) do
    # runs on task completion - can be ignored
    {:noreply, state}
  end
  def handle_info({:DOWN, _ref, _process, _pid, reason} = _msg, state) do
    IO.puts("Task Failed")
    %{:client => client} = state
    # runs on task fail
    # log and notify about err, que next check
    send(client.pid, {:overseer_reply, :task_failed})
    EiLogger.log(:error, {:task_failed, reason, get_module_mame()})
    {:noreply, %{state | :is_working? => false, :client => nil}}
  end
  def handle_info(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end
  defp get_module_mame(), do: Atom.to_string(__MODULE__)
  defp maybe_start_task(state, from, call, task_fun) do
    if state.is_working? do
      new_client = %Client{
        pid: elem(from, 0),
        fun: task_fun,
        call: call
      }
      new_reserved_by =
        [new_client | Enum.reverse(state.reserved_by)] |> Enum.reverse()
      {:reply, :postponed, %{state | reserved_by: new_reserved_by}}
    else
      task = task_fun.()
      new_client = %Client{
        pid: elem(from, 0),
        ref: task.ref,
        call: call
      }
      {:reply, :working, %{state | is_working?: true, client: new_client}}
    end
  end
  defp maybe_start_task_with_arg(state, from, call, task_fun, arg) do
    if state.is_working? do
         new_client = %Client{
        pid: elem(from, 0),
        fun: task_fun,
        call: call,
        arg: arg
      }
      new_reserved_by =
        [new_client | Enum.reverse(state.reserved_by)] |> Enum.reverse()
      {:reply, :postponed, %{state | reserved_by: new_reserved_by}}
    else
      task = task_fun.(arg)
      new_client = %Client{
        pid: elem(from, 0),
        ref: task.ref,
        call: call
      }
      {:reply, :working, %{state | is_working?: true, client: new_client}}
    end
  end
  defp maybe_start_chunked_task(state, from, call, chunk_list, chunk_size, task_fun, region_id) do
    id = :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
    if state.is_working? do
      new_client = %Client{
        id: id,
        pid: elem(from, 0),
        fun: task_fun,
        call: call,
        arg: region_id,
        chunks: chunk_list,
        chunk_size: chunk_size
      }
      new_reserved_by =
        [new_client | Enum.reverse(state.reserved_by)]
        |> Enum.reverse()
      {:reply, :postponed, %{state | reserved_by: new_reserved_by}}
    else
      chunks = Enum.chunk_every(chunk_list, chunk_size)

      [first_chunk | remaining_chunks] = chunks

      Logger.info("Started fetching data for #{length(first_chunk)} entries... | #{length(remaining_chunks)} sets left...")

      task = task_fun.({region_id, first_chunk})

      new_client = %Client{
        id: id,
        pid: elem(from, 0),
        ref: task.ref,
        fun: task_fun,
        call: call,
        arg: region_id,
        chunks: first_chunk,
        chunk_size: chunk_size,
        called: DateTime.now!("Etc/UTC")
      }
      reservations = Enum.map(remaining_chunks, fn chunk ->
      %Client{
        id: id,
        pid: elem(from, 0),
        ref: task.ref,
        fun: task_fun,
        call: call,
        arg: region_id,
        chunks: chunk,
        chunk_size: chunk_size,
        called: DateTime.now!("Etc/UTC")
      }
      end)
      new_reservations = [state.reserved_by | reservations] |> Enum.filter(fn r -> r != [] end)
      new_state = %{state | :reserved_by => new_reservations}
      IO.inspect(new_client)
      {:reply, :working, %{new_state | is_working?: true, client: new_client}}
    end
  end
  defp maybe_continue_chunked_task(%Client{} = client, state) do
    if client.chunks != nil and length(client.chunks) > 0 do
    diff = DateTime.diff(DateTime.now!("Etc/UTC"), client.called)
    delay_ms = max(diff * 1000, 0)

    # Re-add client to reserved queue to continue with next chunk
    Process.send_after(self(), {:add_to_reserved, %{client | called: DateTime.now!("Etc/UTC")}}, delay_ms)
    Process.send_after(self(), {:handle_reserved}, 2000)

    {:noreply, state}
  else
    # No more chunks: send completion & update state
    send(client.pid, {:overseer_reply, :completed})

    new_reserved_by = Enum.reject(state.reserved_by, fn r -> r.pid == client.pid end)

    next_state =
      if length(new_reserved_by) > 0 do
        Process.send_after(self(), {:handle_reserved}, 2000)
        %{state | reserved_by: new_reserved_by, client: nil}
      else
        %{state | is_working?: false, client: nil, reserved_by: new_reserved_by}
      end

    {:noreply, next_state}
  end
  end
  defp handle_market_call(%{:client => _client, :reserved_by => reserved_by, :is_working? => _is_working?, :routes_info => %{:market_orders => %{"status" => "green"}}} = state) do
    reserver = hd(reserved_by)
  %{:fun => fun} = reserver
    task = fun.(reserver.arg)
    new_client = %Client{
        id: reserver.id,
        pid: reserver.pid,
        ref: task.ref,
        call: reserver.call,
        arg: reserver.arg,
        called: DateTime.now!("Etc/UTC")
      }
    new_reserved_by = Enum.drop(reserved_by, 1)
    state = %{state | :reserved_by => new_reserved_by}
    {:noreply, %{state | :client => new_client}}
  end

  defp handle_market_call(%{:client => _client, :reserved_by => _reserved_by, :is_working? => _is_working?, :routes_info => %{:market_orders => %{"status" => _status}}} = state) do
    Process.send_after(self(), {:handle_reserved}, 2000)
    {:noreply, drop_first_reservation_to_bottom(state)}
  end
  defp handle_version_call(%{:client => _client, :reserved_by => reserved_by, :is_working? => _is_working?, :routes_info => %{:market_orders => %{"status" => "green"}}} = state) do
    reserver = hd(reserved_by)
    %{:fun => fun} = reserver
    task = fun.()
    new_client = %Client{
        id: reserver.id,
        pid: reserver.pid,
        ref: task.ref,
        call: reserver.call,
        arg: reserver.arg,
        called: DateTime.now!("Etc/UTC")
      }
    new_reserved_by = Enum.drop(reserved_by, 1)
    state = %{state | :reserved_by => new_reserved_by}
    {:noreply, %{state | :client => new_client}}
  end
  defp handle_prices_call(%{:client => _client, :reserved_by => reserved_by, :is_working? => false, :routes_info => %{:average_prices => %{"status" => "green"}}} = state) do
    reserver = hd(reserved_by)
    %{:fun => fun} = reserver
    task = fun.()
    new_client = %Client{
        id: reserver.id,
        pid: reserver.pid,
        ref: task.ref,
        call: reserver.call,
        arg: reserver.region_id,
        called: DateTime.now!("Etc/UTC")
      }
    new_reserved_by = Enum.drop(reserved_by, 1)
    state = %{state | :reserved_by => new_reserved_by}
    {:noreply, %{state | :client => new_client}}
  end
  defp handle_prices_call(%{:client => _client, :reserved_by => _reserved_by, :is_working? => false, :routes_info => %{:average_prices => %{"status" => _status}}} = state) do
    Process.send_after(self(), {:handle_reserved}, 2000)
    {:noreply, drop_first_reservation_to_bottom(state)}
  end
  defp handle_statistics_call(%{:client => _client, :reserved_by => reserved_by, :is_working? => _is_working?, :routes_info => %{:market_statistics => %{"status" => "green"}}} = state) do
    # IO.puts("received :handle_statistics with :route_info.status = green | should start next position in queue and inject next chunk as first reserved or if no reservations present, wait for some time and start fetching rest of the chunks")
    reserver = hd(reserved_by)
    %{:id => id, :arg => arg, :fun => fun,:pid => pid, :call => call,:called => called, :chunks => chunks} = reserver
    {task, chunks} =
    if !is_nil(called) and DateTime.diff(DateTime.now!("Etc/UTC"), called) >= 10 do
      task = fun.({arg, chunks})
      chunks_left = Enum.drop(chunks, 1)
      {task, chunks_left}
    else

      {%{:ref => nil}, chunks}
    end

    if length(chunks) == 0 do
        new_client = %Client{:pid => pid, :chunks => nil}
        new_state = %{state | :reserved_by => Enum.drop(reserved_by, 1)}
        Process.send_after(self(), {:handle_reserved}, 2000)
        {:noreply, %{new_state | :client => new_client}}
      else
        client = %Client{:id => id,:pid => pid, :fun => fun, :ref => task.ref, :arg => arg, :call => call, :chunks => chunks, :called => DateTime.now!("Etc/UTC")}
        new_state = %{state | :client => client}
        Process.send_after(self(), {:handle_reserved}, 10000)
        {:noreply, push_non_chunked_reservation_to_top(new_state)}
    end
  end
  # defp handle_statistics_call(%{:client => client, :reserved_by => _reserved_by, :is_working? => _is_working?, :routes_info => %{:market_statistics => %{"status" => "green"}}} = state) do
  #   IO.puts("received :handle_statistics with :route_info.status = green // will it even run?")
  #   client = if Map.has_key?(client, :called), do: client, else: Map.put(client, :called, DateTime.now!("Etc/UTC"))
  #   if DateTime.diff(DateTime.now!("Etc/UTC"), client.called) > 60 do

  #     chunks = client.chunks
  #     # Logger.info("Started fething data for #{inspect(length(hd(chunks)))} entries... | #{inspect(length(Enum.drop(chunks, 1)))} sets left...")
  #     task = Task.Supervisor.async_nolink(EveIndustrex.TaskSupervisor, Update, :market_statistics, [client.arg, hd(client.chunks)])
  #     chunks_left = Enum.drop(chunks, 1)
  #     if length(chunks_left) > 0 do
  #       new_state = %{state | :client => %{:pid => pid, :ref => task.ref, :chunks => chunks_left, :called => DateTime.now!("Etc/UTC")}}
  #       {:noreply, new_state}
  #     else
  #       Process.send_after(self(), {:handle_reserved}, 2000)
  #       {:noreply, state}
  #     end
  #   else
  #       diff = DateTime.diff(DateTime.now!("Etc/UTC"), client.called)
  #       Process.send_after(self(), {:handle_reserved}, diff * 1000)
  #     {:noreply, state}
  #   end
  # end
  defp handle_statistics_call(%{:client => client, :reserved_by => _reserved_by, :is_working? => _is_working?, :routes_info => %{:market_statistics => %{"status" => _status}}} = state) do
    %{:reserved_by => reserved_by} = state
    new_reserved_by = [client | Enum.reverse(tl(reserved_by))] |> Enum.reverse()
    Process.send_after(self(), {:handle_reserved}, 2000)
    {:noreply, %{state | :reserved_by => new_reserved_by}}
  end
  defp push_non_chunked_reservation_to_top(state) do
    %{:reserved_by => reserved_by} = state
    non_chunked_reservation = Enum.find(reserved_by, fn r -> r.chunks == nil end)
    if is_nil(non_chunked_reservation) do
      state
    else
      reserved_by |> Enum.drop(1) |> List.insert_at(0, non_chunked_reservation)
      %{state | :reserved_by => reserved_by}
    end
  end
  defp drop_first_reservation_to_bottom(state) do
    %{:reserved_by => reserved_by} = state
    reserved_by |> Enum.drop(1) |> Enum.reverse() |> List.insert_at(0, hd(reserved_by)) |> Enum.reverse()
    %{state | :reserved_by => reserved_by}
  end
end
