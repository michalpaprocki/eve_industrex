defmodule EveIndustrex.Infrastructure.Cache do
  require Logger
  use GenServer

  def init(_init_arg) do
    :ets.new(:regions, [:set, :named_table, :compressed, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:region_constellations, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:constellation_systems, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:system_locations, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:categories, [:set, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:category_groups, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:market_groups, [:set, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:market_group_children, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    :ets.new(:market_types, [:bag, :named_table, :public, read_concurrency: true, write_concurrency: :auto])
    {:ok, %{}}
  end
  def start_link(_) do
    Logger.info("Starting #{__MODULE__}...")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end
end
