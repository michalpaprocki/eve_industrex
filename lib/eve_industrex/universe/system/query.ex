defmodule EveIndustrex.Universe.System.Query do
  import Ecto.Query
  alias EveIndustrex.Universe.System
  alias EveIndustrex.Repo

  def get_systems_for_cache, do: from(s in System, select: {s.constellation_id, s.system_id, s.name}) |> Repo.all
end
