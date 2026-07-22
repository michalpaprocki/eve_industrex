defmodule EveIndustrex.Infrastructure.ESI.Endpoints.Group do
  @group_url "https://esi.evetech.net/universe/groups/"

  def compose(id) when is_binary(id) do
    @group_url<>id
  end
  def compose(id) when is_number(id) do
    @group_url<>Integer.to_string(id)
  end
end
