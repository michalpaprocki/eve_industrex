defmodule EveIndustrex.Bootstrap.InitTask do
  use Task

  def start_link(_arg) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    EveIndustrex.Bootstrap.run()
  end
end
