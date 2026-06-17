defmodule EveIndustrex.Universe.Constellation.Query do
  import Ecto.Query
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Universe.Constellation
  alias EveIndustrex.Repo

  # def get_constellations_for_cache, do: from(c in Constellation, select: {c.region_id, c.constellation_id, c.name}) |> Repo.all
  def get_constellations_for_cache() do
    Constellation
    |> Repo.all()
    |> Repo.preload(:systems)
    |> Enum.map(fn c ->
      {c.constellation_id, c.name, Enum.map(c.systems, & &1.system_id)}
    end)
  end
end
