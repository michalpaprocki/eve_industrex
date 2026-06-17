defmodule EveIndustrex.Infrastructure.Cache do
  require Logger
  use GenServer

  def init(_init_arg) do
    :ets.new(:regions, [:set, :named_table, :compressed, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:constellations, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:systems, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:stations, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:categories, [:set, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:category_groups, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:market_groups, [:ordered_set, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:market_group_children, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:market_types, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:market_types_lookup, [:set, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:npc_corps, [:set, :named_table, :compressed, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:lp_offers, [:set, :named_table, :compressed, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:corp_offers, [:set, :named_table, :compressed, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:blueprints, [:set, :named_table, :compressed, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:types, [:set, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    tid_trade_hub_bid_ask_spread =:ets.new(:undefined, [:bag, :public, read_concurrency: true, write_concurrency: true])
    tid_market_orders =:ets.new(:undefined, [:bag, :public, read_concurrency: true, write_concurrency: true])
    :persistent_term.put(:market_orders_tid, tid_market_orders)
    :persistent_term.put(:trade_hub_bid_ask_spread_tid, tid_trade_hub_bid_ask_spread)
    {:ok, %{generations: %{:market_orders => 0}}}
  end
  def start_link(_) do
    Logger.info("Starting #{__MODULE__}...")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
  def create_trade_hub_bid_ask_spread_table() do
    GenServer.call(__MODULE__, :create_trade_hub_bid_ask_spread_table)
  end
  def create_market_orders_table() do
    GenServer.call(__MODULE__, :create_market_orders_table)
  end
  def get_current_generation(store) do
    GenServer.call(__MODULE__, {:get_current_gen, store})
  end
  def update_generation(store, gen) do
    GenServer.cast(__MODULE__, {:update_generation, store, gen})
  end
  def handle_call(:create_trade_hub_bid_ask_spread_table, _from,state) do
      new_tid = :ets.new(:undefined, [:bag, :public, read_concurrency: true, write_concurrency: true])
    {:reply, new_tid, state}
  end
  def handle_call(:create_market_orders_table, _from,state) do
      new_tid = :ets.new(:undefined, [:bag, :public, read_concurrency: true, write_concurrency: true])
    {:reply, new_tid, state}
  end
  def handle_call({:get_current_gen, store}, _from, state) do

    if Map.has_key?(state.generations, store) do
      gen = Map.get(state.generations, store)

      {:reply, gen, state}
    else

      {:reply, :non_existent, state}
    end
  end
  def handle_cast({:update_generation, store, gen}, state) do
    map = put_in(state[:generations][store], gen)

    {:noreply, map}
  end

end
