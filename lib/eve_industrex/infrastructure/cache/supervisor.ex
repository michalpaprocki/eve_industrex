defmodule EveIndustrex.Infrastructure.Cache.Supervisor do
  use Supervisor
  alias EveIndustrex.Infrastructure.Cache

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, [], name: :cache_supervisor)
  end
  def init(_init_arg) do
    children = [Cache]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
