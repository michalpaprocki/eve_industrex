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

  def available?(rate_limit_group, threshold \\ 10) do
    GenServer.call(__MODULE__, {:available?, rate_limit_group, threshold})
  end
  def check() do
      GenServer.call(__MODULE__, {:check})
  end
  def observe(%Headers{} = headers) do
    GenServer.cast(__MODULE__, {:observe, headers})
  end
  def cooldown(%Headers{} = headers) do
    GenServer.cast(__MODULE__, {:cooldown, headers})
  end
  def handle_call({:check}, _from, state) do
    rl = :ets.tab2list(:rate_limiter)
    {:reply, rl, state}
  end
  def handle_call({:available?, rate_limit_group, threshold}, _from, state) do
    group = rate_limit_group

    case :ets.lookup(:rate_limiter, group) do
      [{^group, %Bucket{} = bucket}] ->
        cond do
          cooldown_active?(bucket) ->
            {:reply, false, state}
          bucket.remaining > threshold ->
            {:reply, true, state}
          true ->
            {:reply, false, state}
        end
      [] ->
        {:reply, true, state}
    end
  end
  def handle_cast({:observe, %Headers{} = headers}, state) do
    :ets.insert(:rate_limiter, {headers.rate_limit_group, Bucket.new(headers)})
    {:noreply, state}
  end
  def handle_cast({:cooldown, %Headers{} = headers}, state) do
    cooldown =
    DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.add(headers.retry_after, :second)
    :ets.insert(:rate_limiter, {headers.rate_limit_group, Bucket.new(headers, cooldown)})
    {:noreply, state}
  end
  defp cooldown_active?(%Bucket{cooldown_until: nil} = _bucket), do: false

  defp cooldown_active?(%Bucket{} = bucket) do
     DateTime.before?(DateTime.utc_now(), bucket.cooldown_until)
  end
end
