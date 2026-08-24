defmodule EveIndustrex.Universe.System.Query do
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Repo
  @moduledoc false
  def get_systems_for_cache do
    System
    |> Repo.all()
    |> Repo.preload(:stations)
    |> Enum.map(fn system ->
      {system.system_id, system.name, system.security_status,
       Enum.map(system.stations, & &1.station_id)}
    end)
  end

  def get_systems() do
    Repo.all(System)
  end
end
