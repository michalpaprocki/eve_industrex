defmodule EveIndustrex.Universe.Station.Sync do

  alias EveIndustrex.ESI.Universe

  def update_from_ESI!(stations_ids) do
    Universe.fetch_stations!(stations_ids)
  end
end
