defmodule EveIndustrex.Market.AveragePrice.Query do
  import Ecto.Query
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Repo
  alias EveIndustrex.Market.AveragePrice

  def get_average_prices_for_published_types() do
    query = from(t in Type, where: t.published == true)
    from(ap in AveragePrice, join: t in subquery(query), on: ap.type_id == t.type_id) |> Repo.all
  end
end
