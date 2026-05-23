defmodule EveIndustrex.Infrastructure.ESI.RateLimiter do
  alias EveIndustrex.Infrastructure.ESI.RateLimiter.Bucket
  alias EveIndustrex.Infrastructure.ESI.{Headers}
  use GenServer
  require Logger
  def init(_init_arg) do
    :ets.new(:rate_limiter, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  def start_link(_arg) do
    Logger.info("Starting #{__MODULE__}...")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def request(rate_limit_group) do
    GenServer.call(__MODULE__, {:request, rate_limit_group})
  end
  def check() do
      GenServer.call(__MODULE__, {:check})
  end
  def observe(%Headers{} = headers) do
    GenServer.cast(__MODULE__, {:observe, headers})
  end
  def handle_call({:check}, _from, state) do
    rl = :ets.tab2list(:rate_limiter)
    {:reply, rl, state}
  end
  def handle_call({:request, rate_limit_group}, _from, state) do
    group = rate_limit_group


    case :ets.lookup(:rate_limiter, group) do
      [{^group, %Bucket{} = bucket}] ->

        if bucket.remaining > bucket.group_penalty_cost do
          :ets.insert(:rate_limiter, {group, Bucket.reserve(bucket)})
          {:reply, :ok, state}
        else
          {:reply, :postpone, state}
        end
      [] ->
        {:reply, :ok, state}
    end
  end
  def handle_cast({:observe, %Headers{} = headers}, state) do
    :ets.insert(:rate_limiter, {headers.rate_limit_group, Bucket.new(headers)})
    {:noreply, state}
  end
end
