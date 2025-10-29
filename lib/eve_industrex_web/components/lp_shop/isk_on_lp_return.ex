defmodule EveIndustrexWeb.LpShop.IskOnLpReturn do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component


  def update_component(cid, %{:update => data}) do

    send_update(__MODULE__, id: cid, update: data)
  end

  def update(%{:update => %{:total_bp_materials_cost => total}}, socket) do
    {:ok, socket |> assign(:total_bp_materials_cost, total)}
  end
    def update(%{:update => %{:new_tax_rate => tax_rate}}, socket) do
    {:ok, socket |> assign(:tax_rate, tax_rate)}
  end
  def update(%{:update => %{:product_price => price}}, socket) do

    {:ok, socket |> assign(:product_price, price)}
  end

  def update(%{:update => %{:req_item => %{:amount => amount, :cost => cost, :type_id => type_id}}}, socket) do

      %{:req_items => prev_items} = socket.assigns
      if cost == nil do
        req_items = Enum.map(prev_items, fn m -> if m.type_id != type_id, do: m, else: %{:type_id => type_id, :cost => nil, :valid? => false} end)

        {:ok, socket |> assign(:req_items, req_items)}
      else

        req_items = Enum.map(prev_items, fn m -> if m.type_id != type_id, do: m, else: %{:type_id => type_id, :cost => cost * amount, :valid? => true} end)


        {:ok, socket |> assign(:req_items, req_items)}
      end
  end
  def update(assigns, socket) do

    %{:req_items => req_items, :ri_orders => ri_orders, :product_orders => product_orders, :is_blueprint? => is_blueprint?} = assigns
    product_price = if length(product_orders) > 0, do: hd(product_orders).price, else: nil

    product_amount = if Map.has_key?(assigns, :portion_size), do: assigns.portion_size * assigns.amount, else: assigns.amount
    req_items =
      if length(req_items) > 0 do
        Enum.map(req_items, fn ri -> extract_ri(ri, Enum.filter(ri_orders |> List.flatten(), fn o -> o.type_id == ri.type_id end)) end)
      else
        []
      end
    total_bp_materials_cost = if is_blueprint?, do: :loading, else: 0
    {:ok, socket |> assign(assigns) |> assign(:product_price, product_price) |> assign(:product_amount, product_amount) |> assign(:req_items, req_items) |> assign(:total_bp_materials_cost, total_bp_materials_cost)}
  end

  def render(assigns) do

    ~H"""
      <div class="">
      <%= cond do %>
        <% @total_bp_materials_cost == :loading -> %>
          <div class={"p-2 mx-auto h-6 w-6 rounded-full border-solid border-2 border-[black_transparent_black_transparent] animate-spin"}/>
        <% @product_price == nil -> %>
          No product price set
        <% length(@req_items) > 0 && Enum.any?(@req_items, fn x -> Map.has_key?(x, :valid?) && x.valid? == false end) -> %>
          Missing required item price
        <% @total_bp_materials_cost == nil -> %>
          Missing material price
        <% @lp_cost == 0 -> %>
          <%!-- <%= Utils.format_with_coma((((@product_price * ((100 - @tax_rate) / 100)) * @product_amount ) - (@isk_cost + List.foldl(@req_items, 0, fn ri, acc -> ri.cost + acc end) + (@total_bp_materials_cost * @amount))))  <>" Profit" %> --%>
          <%= Utils.format_with_coma(calc_isk_per_lp(@lp_cost, {@product_price, @product_amount}, @isk_cost, @tax_rate, @req_items, {@total_bp_materials_cost, @amount}, @offer_id))  <>" Profit" %>
        <% true -> %>
          <%!-- <%= Utils.format_with_coma((((@product_price * ((100 - @tax_rate) / 100)) * @product_amount ) - (@isk_cost + List.foldl(@req_items, 0, fn ri, acc -> ri.cost + acc end) + (@total_bp_materials_cost * @amount))) / @lp_cost)  <>" ISK per LP" %> --%>
          <%= Utils.format_with_coma(calc_isk_per_lp(@lp_cost, {@product_price, @product_amount}, @isk_cost, @tax_rate, @req_items, {@total_bp_materials_cost, @amount}, @offer_id))  <>" ISK per LP" %>
          <%!-- <%= Utils.format_with_coma(@product_price * (100 - @tax_rate) / 100) %> * <%=@product_amount %> - (<%= Utils.format_with_coma(List.foldl(@req_items, 0, fn ri, acc -> ri.cost + acc end)) %> + <%= Utils.format_with_coma(@total_bp_materials_cost) %> * <%= @amount %> / <%= @lp_cost %> = <%= Utils.format_with_coma((((@product_price * ((100 - @tax_rate) / 100)) * @product_amount ) - (@isk_cost + List.foldl(@req_items, 0, fn ri, acc -> ri.cost + acc end) + (@total_bp_materials_cost * @amount))) / @lp_cost)  <>" ISK per LP" %> --%>

      <% end %>
      </div>
    """
  end
  defp extract_ri(req_items, orders) do
    if length(orders) == 0 do
      %{:type_id => req_items.type_id, :cost=> nil, :valid? => false}
    else
      %{:type_id => req_items.type_id, :cost=> hd(orders).price * req_items.quantity, :valid? => true}
    end
  end
  defp calc_isk_per_lp(0, {product_price, product_amount}, isk_cost, tax_rate, req_items, {total_bp_materials_cost, amount}, offer_id) do
    isk_per_lp =
    (((product_price * ((100 - tax_rate) / 100)) * product_amount ) - (isk_cost + List.foldl(req_items, 0, fn ri, acc -> ri.cost + acc end) + (total_bp_materials_cost * amount)))
    send(self(), {:isk_per_lp, %{:isk_per_lp => isk_per_lp, :offer_id => offer_id}})
    isk_per_lp
  end
  defp calc_isk_per_lp(lp_cost, {product_price, product_amount}, isk_cost, tax_rate, req_items, {total_bp_materials_cost, amount}, offer_id) do
    isk_per_lp = (((product_price * ((100 - tax_rate) / 100)) * product_amount ) - (isk_cost + List.foldl(req_items, 0, fn ri, acc -> ri.cost + acc end) + (total_bp_materials_cost * amount))) / lp_cost
    send(self(), {:isk_per_lp, %{:isk_per_lp => isk_per_lp, :offer_id => offer_id}})
    isk_per_lp
  end
end
