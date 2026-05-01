defmodule EveIndustrex.Jobs.Worker do
  alias EveIndustrex.Jobs.Job

  def run(%Job{worker: :market_orders} = job) do
    IO.inspect(job.args)
  end
end
