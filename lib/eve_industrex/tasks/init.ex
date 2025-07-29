defmodule EveIndustrex.Tasks.Init do
  use Task
  alias EveIndustrex.Repo
  alias EveIndustrex.Schemas.{Region, Constellation, System, Station, Category, Group, MarketGroup,Type, Material, NpcCorp, LpOffer, LpReqItem, Blueprint}

  def start_link(arg) do
    Task.start_link(__MODULE__, :check_app_db, arg)
  end
  def start() do
    task = Task.async(__MODULE__, :check_app_db, [])
    Task.await(task)
  end
  def check_app_db() do
    case get_present_records() do
      {false, counts }->
        :populate_db

      {true} ->
        :done
    end
  end
  defp get_present_records() do
    schemas = [Region, Constellation, System, Station, Category, Group, MarketGroup,Type, Material, NpcCorp, LpOffer, LpReqItem, Blueprint]
    counts = Enum.map(schemas, fn s -> {s, Repo.aggregate(s, :count)} end)
    if Enum.any?(counts, fn {_schema, count} -> count == 0 end) do
      {false, Enum.filter(counts, fn {_schema, count} -> count == 0 end)}
    else
      {true}
    end
  end
end
