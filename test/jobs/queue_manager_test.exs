defmodule OverseerTest do
  use ExUnit.Case
  alias EveIndustrex.Jobs.Job
  alias EveIndustrex.Jobs.QueueManager

  setup_all do
    {:ok, _pid} = QueueManager.start_link([])
    job = %Job{id: 0, worker: :test}
    QueueManager.add_job(job)
    {:ok, %{}}
  end
  test "returns an error when starting already started QueueManager genserver" do
    {status, {:already_started, pid}} = QueueManager.start_link([])
    assert(status == :error)
    assert(is_pid(pid))
  end
  test "adds a job to the QueueManager queue" do
    job = %Job{id: 1, worker: :test}
    resp = QueueManager.add_job(job)
    assert(resp ==  :ok)
  end
  test "gets the current job" do
    job = QueueManager.get_current_job()

    assert(job == %Job{id: 0, worker: :test})
  end
end
