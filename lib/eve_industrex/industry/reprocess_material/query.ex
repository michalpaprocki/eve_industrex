defmodule EveIndustrex.Industry.ReprocessMaterial.Query do
  import Ecto.Query
  alias EveIndustrex.Repo
  alias EveIndustrex.Industry.ReprocessMaterial

  def get_all() do
    Repo.all(ReprocessMaterial)
  end

  def for_projection() do
    from(rm in ReprocessMaterial,
      select:
        {rm.source_type_id, rm.material_type_id, rm.quantity, rm.quantity_min, rm.quantity_max}
    )
    |> Repo.all()
  end
end
