defmodule EveIndustrex.Infrastructure.ESI.Endpoints.Station do
  @station_url "https://esi.evetech.net/universe/stations/"

  def compose(station_id) do
    @station_url<>~s"#{station_id}"
  end
end
