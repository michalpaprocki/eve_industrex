defmodule EveIndustrex.Universe.Station.Import do
  alias EveIndustrex.Universe.Station.Sync
  alias EveIndustrex.Universe.Station.Persistence
  alias EveIndustrex.Universe.Station.Mapper

  alias EveIndustrex.Infrastructure.Parsers.Jsonl

  def from_esi() do
    stations_ids = Jsonl.read_jsonl(Jsonl.get_stations_path) |> Mapper.dump_to_ids()
    data = Sync.update_from_ESI(stations_ids)
    stations = Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, data, fn d -> Mapper.from_esi(d) end) |> Enum.map(fn {:ok, s} -> s end)
    Persistence.upsert_all(stations)
  end
  def one_from_esi(station_id) do
    Sync.update_from_ESI([station_id]) |> Enum.map(fn s -> Mapper.from_esi(s) end)
  end
end
