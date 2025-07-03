defmodule EveIndustrexWeb.Alchemy.Total do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  def update_component(cid, %{:material_id => id, :price => price, :amount=> amount}) do
    send_update(__MODULE__, id: cid, update: %{:material_id => id, :price => price, :amount=> amount})
  end
  def update(%{:update => %{:material_id => id, :price => price, :amount=> amount}}, socket) do
    mats = if Map.has_key?(socket.assigns, :mats) and socket.assigns.mats != nil, do: socket.assigns.mats, else: []

    if price == nil do
      array = [{id, 0 * amount} | mats]
      total = Enum.uniq_by(array, fn x -> elem(x,0) end)
    {:ok, socket |> assign(:mats, total)}
    else
      array = [{id, price * amount} | mats]
      total = Enum.uniq_by(array, fn x -> elem(x,0) end)
    {:ok, socket |> assign(:mats, total)}
    end
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class="p-1 flex justify-end min-h-10">
        <span class="font-semibold text-lg">
        <%= if Map.has_key?(assigns, :mats) and @mats != nil do %>
         Total:  <%= Utils.format_with_coma(Enum.reduce(Enum.map(@mats, fn m -> elem(m, 1) end), fn r, acc ->   r + acc end)) %> &nbsp;ISK
        <% else %>
        N/A
        <% end %>
        </span>
      </div>
    """
  end

end
