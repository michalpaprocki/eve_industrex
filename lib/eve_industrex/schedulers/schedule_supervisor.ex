defmodule EveIndustrex.Schedulers.ScheduleSupervisor do
  alias EveIndustrex.Universe
  use Supervisor

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, [], name: :schedule_supervisor)
  end

  def init(_arg) do
    region_ids = Universe.get_regions_ids()
    children =
      Enum.map(region_ids, fn id ->
        %{:id => id, :start => {EveIndustrex.Schedulers.MarketOrder, :start_link, [id]}}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
