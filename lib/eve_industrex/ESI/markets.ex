defmodule EveIndustrex.ESI.Markets do

  alias EveIndustrex.Utils
  @market_groups_url "https://esi.evetech.net/latest/markets/groups/"
  @average_market_prices_url "https://esi.evetech.net/latest/markets/prices/?datasource=tranquility"
  @market_orders_url "https://esi.evetech.net/latest/markets/"
  @market_statistics_url "https://esi.evetech.net/markets/"

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
        data = Task.await(task)
        {:ok, data}
    end
  end
  def fetch_market_statistics(region_id, list_of_type_ids) when is_number(region_id) and is_list(list_of_type_ids) do
    case Utils.can_fetch?(@market_statistics_url<>Integer.to_string(region_id)<>"/history?type_id="<>Integer.to_string(hd(list_of_type_ids))) do
      {false, error}->
        {:error, error}
      true ->
        statistics = Task.Supervisor.async_stream(EveIndustrex.TaskSupervisor, list_of_type_ids, fn type_id ->
          {type_id, Utils.fetch_from_url!(@market_statistics_url<>Integer.to_string(region_id)<>"/history?type_id="<>Integer.to_string(type_id))}
        end) |> Enum.map(fn x -> elem(x, 1)
        end)
        {:ok, statistics}
    end
  end
  def fetch_market_statistics(region_id, type_id) do
    case Utils.can_fetch?(@market_statistics_url<>Integer.to_string(region_id)<>"/history?type_id="<>Integer.to_string(type_id)) do
      {false, error}->
        {:error, error}
      true ->
        statistics_tuple = {type_id, Utils.fetch_from_url!(@market_statistics_url<>Integer.to_string(region_id)<>"/history?type_id="<>Integer.to_string(type_id))}
        {:ok, statistics_tuple}
      end
  end
end
