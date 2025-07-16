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
    current_pages = get_types_pages_amount()
    types = fetch_types_pages(String.to_integer(current_pages))
    Enum.map(Enum.with_index(types), fn {t, i} -> Utils.fetch_from_url(@types_url<>~s"#{t}", i) end)
  end

  defp fetch_types_pages(page_number, types \\ []) when is_integer(page_number) do

    {status, response = %Req.Response{}} = Req.get(@types_url<>"?datasource=tranquility&page=#{Integer.to_string(page_number)}")

      if  status != :ok , do: raise "An error occured, try again later"

      updated_types = [response.body | types]
      if page_number == 1 do
        List.flatten(updated_types)
      else
        fetch_types_pages(page_number - 1, updated_types)
    end
  end

  def fetch_sample_types() do
    types = Utils.fetch_from_url(@types_url)
    dropped = Enum.drop(types, length(types) - 40)
    Enum.map(dropped, fn d -> Utils.fetch_from_url(@types_url<>~s"#{d}")end)
  end
  defp get_types_pages_amount() do
    request = Req.head(@types_url)
    case request do
      {:ok, response}->
        hd(response.headers["x-pages"])
      {:error, msg} ->
        {:erro, msg}
    end
  end
end
