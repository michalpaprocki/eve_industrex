defmodule EveIndustrex.Industry.SystemCostIndex.Query do
  import Ecto.Query
  alias EveIndustrex.Industry.SystemCostIndex
  alias EveIndustrex.Repo

  def get_system_cost_indices(system_id) do
    from(sci in SystemCostIndex, where: sci.system_id == ^system_id) |> Repo.all()
  end

  def get_all() do
    Repo.all(SystemCostIndex)
  end

  def count() do
    Repo.aggregate(SystemCostIndex, :count)
  end
end
