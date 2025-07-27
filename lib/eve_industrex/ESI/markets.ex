defmodule EveIndustrex.ESI.Markets do
  alias EveIndustrex.ESI.Names
  alias EveIndustrex.Utils
  @market_groups_url "https://esi.evetech.net/latest/markets/groups/"
  @average_market_prices_url "https://esi.evetech.net/latest/markets/prices/?datasource=tranquility"
  def fetch_market_orders(region_id, attempts \\ 10) do
    # 504 returned when servers down
    resp = Code.ensure_loaded(EveIndustrex.Schemas.MarketOrder)
    if resp != {:module, EveIndustrex.Schemas.MarketOrder} && attempts > 0 do
      fetch_market_orders(attempts - 1)
    else
      current_pages = String.to_integer(get_market_orders_pages_amount(region_id))
      fetch_market_order_pages(region_id, current_pages)
    end
  end

  defp get_market_orders_pages_amount(region_id) do
    request = Req.head("https://esi.evetech.net/latest/markets/"<>~s"#{region_id}"<>"/orders/?datasource=tranquility&order_type=all")
    case request do
      {:ok, response}->
        hd(response.headers["x-pages"])
      {:error, msg} ->
        {:erro, msg}
    end
  end

  defp fetch_market_order_pages(region_id, page_number, orders \\ []) when is_integer(page_number) do
    {status, response = %Req.Response{}} = Req.get("https://esi.evetech.net/latest/markets/"<>~s"#{region_id}"<>"/orders/?datasource=tranquility&order_type=all&page=#{Integer.to_string(page_number)}")

      if  status != :ok , do: raise "An error occured, try again later"
      struct_orders = Enum.map(response.body, fn b ->
        for {k,v} <- b, into: %{} do
        {String.to_existing_atom(k), v}
      end
    end)

      updated_orders = [struct_orders | orders]
      if page_number == 1 do
        List.flatten(updated_orders)
      else
        fetch_market_order_pages(region_id, page_number - 1, updated_orders)
    end
  end

  def get_market_types() do
    market_ids = get_market_groups_ids()
    market_types =
      [hd(market_ids), Enum.at(market_ids,33), Enum.at(market_ids,200), Enum.at(market_ids,344), Enum.at(market_ids,453)]
      |> get_market_groups()
      |> prep_market_types()
      |> Names.get_by_ids()
      market_types
  end

  def fetch_market_average_prices() do
    Utils.fetch_from_url(@average_market_prices_url)
  end

  defp get_market_groups_ids() do
    Utils.fetch_from_url(@market_groups_url)
  end
  defp get_market_groups(list) do
    Enum.map(list, fn l ->
    Utils.fetch_from_url(@market_groups_url<>~s"#{l}")
    end)
  end

  defp prep_market_types(list, acc \\ []) do
    if length(list) == 0 do
      Enum.uniq(List.flatten(acc))
    else
      types = extract_types_from_map(hd(list))
      new_acc = [types | acc]
      prep_market_types(Enum.drop(list, 1) ,new_acc)
    end
  end

  defp extract_types_from_map(%{"types" => types} = map) when is_map(map), do: types

end
