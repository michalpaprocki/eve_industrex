defmodule EveIndustrex.Infrastructure.ESI.ClientHandler do

  alias EveIndustrex.Infrastructure.ESI.Headers
  alias EveIndustrex.Infrastructure.ESI.Response



  def handle_response({:ok, %Response{status: status, body: body, headers: %Headers{} = headers} = _response}) do

    cond do
      status == 200 ->
        {:success, body, headers}
      status == 304 ->
        {:not_modified, headers}
      status == 404 ->
        {:not_found, body, headers}
      status == 429 ->
        {:rate_limited, headers}
      status >= 500 ->
        {:server_error, headers, status}
      status >= 400 ->
        {:client_error, body, headers, status}
      status >= 300 ->
        {:unexpected_response, headers, status}

      true ->
        {:invalid_status, headers, status}
    end
  end
end
