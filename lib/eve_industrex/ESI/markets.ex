defmodule EveIndustrex.ESI.Markets do

  alias EveIndustrex.Utils
  @market_groups_url "https://esi.evetech.net/latest/markets/groups/"
  @average_market_prices_url "https://esi.evetech.net/latest/markets/prices/?datasource=tranquility"
  @market_orders_url "https://esi.evetech.net/latest/markets/"

  def fetch_market_orders(region_id) do
    case Utils.can_fetch?(@market_orders_url<>~s"#{region_id}"<>"/orders/?datasource=tranquility&order_type=all") do
      {false, error} ->
        {:error, error}
      true ->
        number_of_pages = Utils.get_ESI_pages_amount!(@market_orders_url<>~s"#{region_id}"<>"/orders/?datasource=tranquility&order_type=all")
        urls = Enum.map(1..number_of_pages, fn page_number ->
          @market_orders_url<>~s"#{region_id}"<>"/orders/?datasource=tranquility&order_type=all&page=#{Integer.to_string(page_number)}"
        end)
        orders = Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, urls, fn url ->
          Utils.fetch_from_url!(url)
        end) |> Enum.map(fn x -> elem(x, 1) end) |> List.flatten()
        {:ok, orders}
    end
  end

  def fetch_market_average_prices() do
    case Utils.can_fetch?(@average_market_prices_url) do
      {false, error} ->
        {:error, error}
      true ->
        task = Task.async(fn -> Utils.fetch_from_url!(@average_market_prices_url) end)
        Task.await(task)
    end
  end

end
