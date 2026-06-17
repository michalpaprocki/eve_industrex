defmodule EveIndustrex.Infrastructure.ESI.Sync.Mapper do
alias EveIndustrex.Infrastructure.ESI.Sync.EsiSyncCache

  def to_resource_type(resource_name) do
    now = get_now()
    %{
      name: resource_name,
      inserted_at: now,
      updated_at: now
    }
  end
  def to_cache(strategy_id, headers, page) do
    now = get_now()
    map = %{
    esi_sync_strategy_id: strategy_id,
    etag: headers.etag,
    expires_at:  DateTimeParser.parse_datetime!(headers.expires_at, to_utc: true)|> DateTime.from_naive!("Etc/UTC")|>DateTime.truncate(:second),
    page_number: page,
    last_checked_at: now
    }
    %EsiSyncCache{}
    |> EsiSyncCache.changest(map)
  end
    defp get_now(), do: DateTime.utc_now() |> DateTime.truncate(:second)
end
