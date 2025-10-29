defmodule EveIndustrexWeb.LpShop.LpBpMaterials do
  use EveIndustrexWeb, :live_component

  def update_component(cid, %{:update => data}) do
    send_update(__MODULE__, id: cid, update: data)
  end
end
