defmodule EveIndustrexWeb.LpShop.IskOnLpReturn do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component


  def update_component(cid, %{:update => data}) do

    send_update(__MODULE__, id: cid, update: data)
  end

  def update(%{:update => %{:total_bp_materials_cost => total}}, socket) do

    {:ok, socket |> assign(:total_bp_materials_cost, total)}
  end
    def update(%{:update => %{:tax_rate => tax_rate}}, socket) do

    {:ok, socket |> assign(:tax_rate, tax_rate)}
  end
  def update(%{:update => %{:product_price => price}}, socket) do

    {:ok, socket |> assign(:product_price, price)}
  end



  def update(%{:update => %{:initial_req_item => %{:amount => amount, :cost => cost, :type_id => type_id}}}, socket) do
    %{:req_items => prev_items} = socket.assigns
    if cost == nil do
      req_items = [%{:type_id => type_id, :cost=> nil, :valid? => false}| prev_items]
      {:ok, socket |> assign(:req_items, req_items)}
    else
      req_items = [%{:type_id => type_id, :cost=> cost * amount, :valid? => true}| prev_items]
      {:ok, socket |> assign(:req_items, req_items)}
    end
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
    send(self(), {:get_tax_rate, __MODULE__, assigns.id})
    req_items = []
    {:ok, socket |> assign(assigns) |> assign(:req_items, req_items) |> assign(:total_bp_materials_cost, 0) |> assign(:product_price, nil)}
  end

  def render(assigns) do
    ~H"""
      <div class="flex flex-col">
      <%= cond do %>
        <% !Map.has_key?(assigns, :tax_rate) -> %>
          <div class={"p-2 mx-auto h-6 w-6 rounded-full border-solid border-2 border-[black_transparent_black_transparent] animate-spin"}/>
        <% @product_price == nil -> %>
          No product price set
        <% length(@req_items) > 0 && Enum.any?(@req_items, fn x -> Map.has_key?(x, :valid?) && x.valid? == false end) -> %>
          Missing required item price
        <% @total_bp_materials_cost ==nil -> %>
          Missing material price
        <% true -> %>
          <%= Utils.format_with_coma((((@product_price * ((100 - @tax_rate) / 100)) * @amount ) - (@isk_cost + List.foldl(@req_items, 0, fn ri, acc -> ri.cost + acc end) + @total_bp_materials_cost)) / @lp_cost)  <>" ISK per LP" %>
      <% end %>
      </div>
    """
  end

end
