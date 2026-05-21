defmodule EveIndustrex.Universe.Region.Query do
  alias EveIndustrex.Universe.Region
  alias EveIndustrex.Repo
  import Ecto.Query
  def get_regions_for_cache, do: from(r in Region, select: {r.region_id, r.name}) |> Repo.all()
  def get_region_by_string(string), do: from(r in Region, where: ilike(r.name,^"%#{string}%")) |> Repo.all
end
