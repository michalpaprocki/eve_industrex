defmodule EveIndustrex.ESI.Types do
alias EveIndustrex.Utils


  @market_groups_url "https://esi.evetech.net/latest/markets/groups/"
  @types_url "https://esi.evetech.net/latest/universe/types/"


  def fetch_market_groups() do
    market_groups_ids = Utils.fetch_from_url(@market_groups_url)
    Enum.map(market_groups_ids, fn mgi -> Utils.fetch_from_url(@market_groups_url<>~s"#{mgi}") end)

  end
  def fetch_type(id) do
    Utils.fetch_from_url(@types_url<>~s"#{id}")
  end
  def fetch_types() do
    current_pages = Utils.get_ESI_pages_amount(@types_url)

    types = Utils.fetch_ESI_pages(@types_url, current_pages)

    Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, Enum.with_index(types), fn {t, i} -> Utils.fetch_from_url(@types_url<>~s"#{t}", i) end) |>
    Enum.to_list()

  end


end
