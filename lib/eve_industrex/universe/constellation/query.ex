defmodule EveIndustrex.Universe.Constellation.Query do
  import Ecto.Query
  alias EveIndustrex.Universe.Constellation
  alias EveIndustrex.Repo

  def get_constellations_for_cache, do: from(c in Constellation, select: {c.region_id, c.constellation_id, c.name}) |> Repo.all
end
