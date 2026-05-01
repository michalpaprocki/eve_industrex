defmodule EveIndustrex.Jobs.QueueManager do

  use GenServer
  alias EveIndustrex.Jobs.{Job, Queue, Worker}
  def init(_init_arg) do
    queue = Queue.new()
    {:ok, %{:queue => queue, :job => nil}}
  end
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end
  def add_job(%Job{} = job) do
    GenServer.call(__MODULE__, {:add_job, job})
  end
  def report_job_complete(status, result) do
    GenServer.cast(__MODULE__, {:job_completed, result})
  end
  def report_job_failed(status, reason) do
    GenServer.cast(__MODULE__, {:job_failed, reason})
  end
  def get_current_job() do
    GenServer.call(__MODULE__, {:get_current})
  end
  def handle_call({:add_job, %Job{} = job}, _from, state) do
    queue = Queue.add(state.queue, job)
    send(self(), :maybe_start_job)
    {:reply, :ok, %{state | :queue => queue}}
  end
  def handle_call({:get_current}, _from, state) do
    {:reply, state.job, state}
  end

  def handle_cast( {:job_completed, result}, state) do
      # handle the result
    {:noreply,:ok, state}
  end
  def handle_cast({:job_failed, reason},state) do
    # handle fail - requeue
    {:noreply,:ok, state}
  end
  def handle_info(:maybe_start_job,%{job: nil} = state) do
    case Queue.take(state.queue) do
      {:ok, job, new_queue} ->
        IO.inspect(job)
        IO.puts("call executor here")
        x = Worker.run(job)
        IO.inspect(x)
        {:noreply, %{state | job: job, queue: new_queue}}
      {:empty, _q} ->
        {:noreply, state}
    end
  end
  def handle_info(:maybe_start_job, state) do
    {:noreply, state}
  end
end
