defmodule EveIndustrex.Jobs.Queue do
  alias EveIndustrex.Jobs.Job

  def new do
    :queue.new()
  end
  def add(queue, %Job{} = job) do
    :queue.in(job, queue)
  end
  def take(queue) do
     case :queue.out(queue) do
        {{:value, job}, q} -> {:ok, job, q}
        {:empty, q} -> {:empty, q}
  end
  end
  def size(queue) do
    :queue.len(queue)
  end
  def peek(queue) do
    :queue.peek(queue)
  end
end
