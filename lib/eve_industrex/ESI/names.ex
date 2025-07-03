defmodule EveIndustrex.ESI.Names do
alias EveIndustrex.Utils
@items_count 1000
  def get_by_ids(list_of_ids) when is_list(list_of_ids) do
    chunked_list = Utils.get_chunked_list(list_of_ids, @items_count)
    for cl <- chunked_list do
      {_req, res} = run_names_request(cl)
      handle_response(res)
    end
  end



  defp run_names_request(list_of_ids) do
    request =
      Req.Request.new(url: "https://esi.evetech.net/latest/universe/names", method: :post, body: Jason.encode!(list_of_ids))
      |> Req.Request.put_header("content", "application/json")
      Req.run(request)
  end

  defp handle_response(%Req.Response{} = res) do

    case res.status do
      200 ->
        {:ok, Jason.decode!(res.body)}
        _->
        {:error, "Could not fetch names"}
    end
  end
end
