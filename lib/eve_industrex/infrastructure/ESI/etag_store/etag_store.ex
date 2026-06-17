defmodule EveIndustrex.Infrastructure.ESI.EtagStore do
  alias EveIndustrex.Infrastructure.ESI.EtagStore.Metadata
  use GenServer
  require Logger
  def init(_init_arg) do
    :ets.new(:etag_store, [:set, :protected, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  def start_link(_arg) do
    Logger.info("Starting #{__MODULE__}...")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_metadata(rate_limit_group, id) do
    GenServer.call(__MODULE__, {:get_metadata, rate_limit_group, id})
  end

  def upsert_metadata(rate_limit_group, id, headers) do

    GenServer.cast(__MODULE__, {:upsert_metadata, rate_limit_group, id, headers})
  end

  def handle_call({:get_metadata, rate_limit_group, id}, _from, state) do
    metadata =
    case :ets.lookup(:etag_store, {rate_limit_group, id}) do
      [{{^rate_limit_group, ^id}, metadata}] ->
        metadata
      [] ->
        :not_found
    end

    {:reply, metadata, state}
  end

  def handle_cast({:upsert_metadata, rate_limit_group, id, headers}, state) do
      if is_nil(headers.expires_at) do
        {:noreply, state}
      else

        tuple = {{rate_limit_group, id}, %Metadata{etag: headers.etag, expires_at: DateTimeParser.parse_datetime!(headers.expires_at, to_utc: true)|> DateTime.from_naive!("Etc/UTC")|>DateTime.truncate(:second)}}
        :ets.insert(:etag_store, tuple)
        {:noreply, state}
      end

  end
end
