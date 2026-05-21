defmodule EveIndustrex.Infrastructure.Bootstrap.InitTask do
  use Task

  def start_link(_arg) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    EveIndustrex.Infrastructure.Bootstrap.run()
  end
end
