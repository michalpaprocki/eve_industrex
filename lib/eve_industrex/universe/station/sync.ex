defmodule EveIndustrex.Universe.Station.Sync do
  alias EveIndustrex.Infrastructure.ESI.Client
  @moduledoc false
  def update_from_esi(stations_ids) do
    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, stations_ids, fn station_id ->
      Client.fetch_station(station_id)
    end)
    |> Enum.map(fn {:ok, data} -> data end)
    |> Enum.map(fn {:ok, response} -> response.body end)
  end
end
