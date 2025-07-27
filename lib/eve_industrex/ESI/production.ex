defmodule EveIndustrex.ESI.Production do
  alias EveIndustrex.Utils
  @index_cost_url "https://esi.evetech.net/latest/industry/systems/?datasource=tranquility"

  def fetch_system_cost_indices() do
    Utils.fetch_from_url(@index_cost_url)
  end
end
