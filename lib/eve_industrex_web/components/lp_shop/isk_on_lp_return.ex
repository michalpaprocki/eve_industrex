defmodule EveIndustrexWeb.LpShop.IskOnLpReturn do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component


  def update_component(cid, %{:update => data}) do

    send_update(__MODULE__, id: cid, update: data)
  end


  def update(assigns, socket) do

    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    # IO.inspect(assigns)
    ~H"""
      <div class="flex flex-col">
      <%= cond do %>
        <% Map.has_key?(@offer, :blueprint) and @offer.prices.products[hd(Enum.find(@offer.blueprint.activities, fn a -> a.activity == :manufacturing end).products).type_id] == nil -> %>
        No product price set
        <% !Map.has_key?(@offer, :blueprint) and @offer.prices.products[@offer.type.type_id] == nil -> %>
        No product price set
        <% Map.has_key?(@offer, :blueprint) and Enum.any?(Enum.find(@offer.blueprint.activities, fn a -> a.activity == :manufacturing end).materials, fn m -> @offer.prices.materials[m.type_id] == nil end) -> %>
          Missing material item price
        <% length(@offer.req_items) > 0 and Enum.any?(@offer.req_items, fn ri -> @offer.prices.req_items[ri.type_id] == nil end) -> %>
          Missing req item price
        <% @offer.lp_cost == 0 -> %>
            <%= Utils.format_with_coma(@offer.profit)  <>" ISK Profit" %>
        <% @offer.isk_on_lp != nil and @offer.profit != nil -> %>
             <span><%= Utils.format_with_coma(@offer.profit)  <>" ISK Profit" %> / <%=  Utils.format_with_coma(@offer.lp_cost) %> LP</span>
             <span class={"font-bold"}>
             <%= Utils.format_with_coma(@offer.isk_on_lp)  <>" ISK per LP" %>
             </span>
        <% true -> %>
          :noop

      <% end %>
      </div>
    """
  end
end
