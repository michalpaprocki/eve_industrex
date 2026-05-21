defmodule EveIndustrex.Universe.Station.Import do
  alias EveIndustrex.Universe.Station.Sync
  alias EveIndustrex.Universe.Station.Persistence
  alias EveIndustrex.Universe.Station.Mapper

  alias EveIndustrex.Infrastructure.Parsers.Jsonl

  def from_esi() do
    stations_ids = Jsonl.read_jsonl(Jsonl.get_stations_path) |> Mapper.dump_to_ids()
    data = Sync.update_from_ESI!(stations_ids)
    stations = Task.async_stream(data, fn d -> Mapper.from_esi(d) end) |> Enum.map(fn {:ok, s} -> s end)
    Persistence.upsert_all(stations)
  end
end
