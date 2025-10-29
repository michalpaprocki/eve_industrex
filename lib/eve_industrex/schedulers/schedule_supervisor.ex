defmodule EveIndustrex.Schedulers.ScheduleSupervisor do
  alias EveIndustrex.{Universe, Types}
  use Supervisor

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, [], name: :schedule_supervisor)
  end

  def init(_arg) do
    type_ids = Types.get_market_type_ids()
    market_hubs_region_ids = Universe.get_trade_hub_regions()
    region_ids = Universe.get_regions_ids()

    market_statistics_children =
      Enum.map(market_hubs_region_ids, fn hub_id ->
        %{:id=> Integer.to_string(hub_id)<>"MStats", :start => {EveIndustrex.Schedulers.MarketStatistics, :start_link, [%{:region_id => hub_id, :list_of_type_ids => type_ids}]}}
      end)


    market_orders_children =
      Enum.map(region_ids, fn id ->
        %{:id => id, :start => {EveIndustrex.Schedulers.MarketOrder, :start_link, [id]}}
      end)
      children = market_statistics_children ++ market_orders_children

    Supervisor.init(children, strategy: :one_for_one)

  end
end
