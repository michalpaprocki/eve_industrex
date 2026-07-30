defmodule EveIndustrex.Infrastructure.ESI.Endpoints.Type do
  @type_url "https://esi.evetech.net/universe/types/"

  def compose(), do: @type_url
  def compose(type_id) when is_binary(type_id), do: @type_url <> type_id
  def compose(type_id) when is_number(type_id), do: @type_url <> Integer.to_string(type_id)
end
