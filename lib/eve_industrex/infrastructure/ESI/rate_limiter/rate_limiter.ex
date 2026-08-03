defmodule EveIndustrex.Infrastructure.ESI.RateLimiter do
  alias EveIndustrex.Infrastructure.ESI.RateLimiter.{Bucket, Global}
  alias EveIndustrex.Infrastructure.ESI.{Headers}
  use GenServer
  require Logger

  @moduledoc """
    Simple rate limit tracking module.
  """
  def init(_init_arg) do
    :ets.new(:rate_limiter, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  def start_link(_arg) do
    Logger.info("Starting #{__MODULE__}...")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def available?(rate_limit_group, threshold \\ 10) do
    group = rate_limit_group

    case :ets.lookup(:rate_limiter, group) do
      [{^group, %Bucket{} = bucket}] ->
        cond do
          cooldown_active?(bucket) ->
            false

          bucket.remaining > threshold ->
            true

          true ->
            false
        end

      [{^group, %Global{} = bucket}] ->
        cond do
          global_cooldown_active?(bucket) ->
            false

          bucket.error_limit_remain > threshold ->
            true

          true ->
            false
        end

      [] ->
        true
    end
  end

  def check() do
    :ets.tab2list(:rate_limiter)
  end

  def observe(%Headers{} = headers) do
    GenServer.cast(__MODULE__, {:observe, headers})
  end

  def cooldown(%Headers{} = headers) do
    GenServer.cast(__MODULE__, {:cooldown, headers})
  end

  def handle_cast({:observe, %Headers{} = headers}, state) do
    if not is_nil(headers.rate_limit_group) do
      :ets.insert(:rate_limiter, {headers.rate_limit_group, Bucket.new(headers)})
    else
      :ets.insert(:rate_limiter, {"global", Global.new(headers)})
    end

    {:noreply, state}
  end

  def handle_cast({:cooldown, %Headers{} = headers}, state) do
    if not is_nil(headers.rate_limit_group) do
      cooldown =
        DateTime.utc_now()
        |> DateTime.truncate(:second)
        |> DateTime.add(headers.retry_after, :second)

      :ets.insert(:rate_limiter, {headers.rate_limit_group, Bucket.new(headers, cooldown)})
    else
      cooldown =
        DateTime.utc_now()
        |> DateTime.truncate(:second)
        |> DateTime.add(headers.global_error_limit_reset, :second)

      :ets.insert(:rate_limiter, {"global", Global.new(headers, cooldown)})
    end

    {:noreply, state}
  end

  defp cooldown_active?(%Bucket{cooldown_until: nil} = _bucket), do: false

  defp cooldown_active?(%Bucket{} = bucket) do
    DateTime.before?(DateTime.utc_now(), bucket.cooldown_until)
  end

  defp global_cooldown_active?(%Global{cooldown_until: nil} = _bucket), do: false

  defp global_cooldown_active?(%Global{} = bucket) do
    DateTime.before?(DateTime.utc_now(), bucket.cooldown_until)
  end
end
