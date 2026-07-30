defmodule EveIndustrex.Universe.System.Query do
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Repo

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

  def get_systems_for_reactions() do
    System.Store.get_all()
    |> Enum.filter(fn x ->
      elem(x, 2) < 0.45
    end)
    |> Enum.map(fn x ->
      %{name: elem(x, 1), system_id: elem(x, 0), security_status: elem(x, 2)}
    end)
  end
end
