defmodule EveIndustrex.Infrastructure.Readiness do
  alias EveIndustrexWeb.Endpoint
  use GenServer
  require Logger

  @moduledoc """
    Purpose of this module is to track application's boostrap state.
  """
  @flags [:bootstrap, :sde_cache, :market_orders, :average_prices, :system_cost_index]
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.info("Starting #{inspect(__MODULE__)}...")
    :ets.new(:readiness, [:named_table, :set, :public, read_concurrency: true])
    Enum.each(@flags, fn f -> :ets.insert(:readiness, {f, false}) end)
    {:ok, %{}}
  end

  def mark_ready(flag) when is_atom(flag) and flag in @flags do
    GenServer.cast(__MODULE__, {:mark_ready, flag})
  end

  def ready?() do
    @flags
    |> Enum.all?(&enabled?/1)
  end

  def enabled?(flag) do
    case :ets.lookup(:readiness, flag) do
      [{^flag, value}] ->
        value

      [] ->
        false
    end
  end

  def read_state() do
    :ets.tab2list(:readiness)
  end

  def handle_cast({:mark_ready, flag}, state) do
    Endpoint.broadcast("readiness", "ready", Atom.to_string(flag))
    :ets.insert(:readiness, {flag, true})
    {:noreply, state}
  end
end
