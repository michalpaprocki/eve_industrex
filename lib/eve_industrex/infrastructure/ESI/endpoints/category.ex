defmodule EveIndustrex.Infrastructure.ESI.Endpoints.Category do
  @category_url "https://esi.evetech.net/universe/categories/"
  @moduledoc false
  def compose(category_id) when is_binary(category_id) do
    @category_url <> category_id
  end

  def compose(category_id) when is_number(category_id) do
    @category_url <> Integer.to_string(category_id)
  end
end
