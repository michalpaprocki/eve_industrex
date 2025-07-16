defmodule EveIndustrexWeb.Alchemy.Total do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  def update_component(cid, %{:material_id => id, :price => price, :amount=> amount, :category => category}) do
    send_update(__MODULE__, id: cid, update: %{:material_id => id, :price => price, :amount=> amount, :category => category})
  end
  def update(%{:update => %{:material_id => id, :price => price, :amount=> amount, :category => :material}}, socket) do

    mats = if Map.has_key?(socket.assigns, :mats) && socket.assigns.mats != nil, do: socket.assigns.mats, else: []

    total =
    if !Enum.any?(mats, fn {type_id, _price} -> type_id == id end) do
      [{id, price * amount} | mats]
    else
      Enum.map(mats, fn {type_id, prev_price} -> if type_id == id, do: {type_id, price * amount}, else: {type_id, prev_price} end)
    end

      EveIndustrexWeb.Alchemy.ReactionProfit.update_component(socket.assigns.profit_component_id, %{:update => %{:material_total => total}})
      {:ok, socket |> assign(:mats, total)}
    end

  def update(%{:update => %{:material_id => id, :price => price, :amount=> amount, :category => :product}}, socket) do
    products = if Map.has_key?(socket.assigns, :products) && socket.assigns.products != nil, do: socket.assigns.products, else: []

    total =
    if !Enum.any?(products, fn {type_id, _price} -> type_id == id end) do
      [{id, price * amount} | products]
    else

      Enum.map(products, fn {type_id, prev_price} -> if type_id == id, do: {type_id, price * amount}, else: {type_id, prev_price} end)
    end

      EveIndustrexWeb.Alchemy.ReactionProfit.update_component(socket.assigns.profit_component_id, %{:update => %{:product_total => total}})
    {:ok, socket |> assign(:products, total)}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do

    ~H"""
      <div class="p-1 flex justify-end min-h-10">
        <span class="font-semibold text-base">
        <%= cond do %>
          <% Map.has_key?(assigns, :mats) and @mats != nil  -> %>
          Total:  <%= Utils.format_with_coma(Enum.reduce(Enum.map(@mats, fn m -> elem(m, 1) end), fn r, acc ->   r + acc end)) %> &nbsp;ISK

          <% Map.has_key?(assigns, :products) and @products != nil  -> %>
          Total:  <%= Utils.format_with_coma(Enum.reduce(Enum.map(@products, fn p -> elem(p, 1) end), fn r, acc ->   r + acc end)) %> &nbsp;ISK
          <% true  -> %>
          N/A
        <% end %>
        </span>
      </div>
    """
  end

end
