defmodule EveIndustrex.Universe.Region.Query do
  alias EveIndustrex.Universe.Region
  alias EveIndustrex.Repo
  import Ecto.Query
  def get_region(region_id), do: Repo.get(Region, region_id)
  def get_regions_for_cache() do
    Region
    |> Repo.all()
    |>Repo.preload(:constellations)
    |> Enum.map(fn r ->
      {r.region_id, r.name, Enum.map(r.constellations, & &1.constellation_id)}
    end)

  end
  def get_region_by_string(string), do: from(r in Region, where: ilike(r.name,^"%#{string}%")) |> Repo.all
end
