 defmodule EveIndustrexWeb.Alchemy.Product do


  use EveIndustrexWeb, :live_component
  @base_reprocess 0.5

    def update_component(cid, %{:update => data}) do

    send_update(__MODULE__, id: cid, update: data)
  end
  def update(%{:update => %{:material_cost => material}}, socket) do
    if socket.assigns.category == :alchemy do
      %{:total_list => prev_total} = socket.assigns
      total_list = Enum.map(prev_total,fn pt -> if pt.type_id == material.type_id, do: %{:type_id => pt.type_id, :id => material.id, :amount => pt.amount, :price => material.price} , else: pt end)

      {:ok, socket |> assign(:total_list, total_list)}
    else
      %{:total_list => prev_total} = socket.assigns
        total_list = if prev_total.type_id == material.type_id, do: %{:type_id => prev_total.type_id, :id => material.id, :amount => prev_total.amount, :price => material.price} , else: prev_total
      {:ok, socket |> assign(:total_list, total_list)}
    end
  end
  def update(%{:update => %{:skill_level => level}}, socket) do

    {:ok, socket |> assign(:selected_skill_level, String.to_integer(level))}
  end
  def update(assigns, socket) do

    if assigns.category == :alchemy do
     amounts_and_orders = Enum.map(assigns.product.product.products, fn p -> %{:amount => p.amount, :type_id => p.material_type_id, :orders => Enum.filter(assigns.orders.result, fn o -> o.type_id == p.material_type_id end) |> Enum.filter(fn o -> o.is_buy_order == false end)} end)

    total_list = Enum.map(amounts_and_orders, fn aao ->  if length(aao.orders) > 0 , do: %{:type_id => aao.type_id, :price => hd(aao.orders).price , :amount =>  aao.amount, :id => hd(aao.orders).order_id}, else: %{:type_id => aao.type_id, :price => nil , :amount =>  aao.amount, :id => nil} end)
    {:ok, socket |> assign(assigns) |> assign(:selected_skill_level, 0) |> assign(:base_reprocess, @base_reprocess) |> assign(:total_list, total_list)}
    else
      amount_and_orders = %{:amount => assigns.product.amount, :type_id => assigns.product.product_type_id, :orders => Enum.filter(assigns.orders.result, fn o -> o.type_id == assigns.product.product_type_id end) |> Enum.filter(fn o -> o.is_buy_order == false end)}

    total_list = if length(amount_and_orders.orders) > 0 , do: %{:type_id => amount_and_orders.type_id, :price => hd(amount_and_orders.orders).price , :amount =>  amount_and_orders.amount, :id => hd(amount_and_orders.orders).order_id}, else: %{:type_id => amount_and_orders.type_id, :price => nil , :amount =>  amount_and_orders.amount, :id => nil}

    {:ok, socket |> assign(assigns) |> assign(:selected_skill_level, 0) |> assign(:base_reprocess, @base_reprocess) |> assign(:total_list, total_list)}
    end
  end

  def render(%{:selected_skill_level => _level} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2 w-full">
      <span class="font-semibold"><%= if @category == :alchemy, do: "Reprocessed into:", else: "Product:" %></span>
      <%= if @category == :alchemy do %>

        <%= for m <- @product.product.products do %>
          <div class="flex items-center justify-between">
            <span><%= m.material_type.name %> <%= floor(m.amount * (@base_reprocess * (1 + (@selected_skill_level * 0.02))))%> </span>
            <div class="flex gap-2 justify-between min-w-[20rem]">

              <.live_component module={EveIndustrexWeb.Common.MiniMarket} selected_order={Enum.filter(@total_list, fn tl -> tl.type_id == m.material_type_id end)}
              reaction_product_id={@id} material_cost_id={~s"#{@id}_#{m.material_type_id}_material_cost"} category={:reaction_product} id={~s"#{@id}_#{m.material_type_id}"} orders={Enum.filter(@orders.result, fn o -> o.type_id == m.material_type_id end)} item={%{:name => m.material_type.name, :type_id => m.material_type.type_id}} amount={m.amount}/>
              <.live_component module={EveIndustrexWeb.Alchemy.MaterialCost} category={:product} id={~s"#{@id}_#{m.material_type_id}_material_cost"} amount={floor(m.amount * (@base_reprocess * (1 + (@selected_skill_level * 0.02))))}/>
            </div>
          </div>
        <% end %>

      <% else %>

          <div class="flex items-center justify-between">
            <span><%= @product.product.name %> <%= @product.amount%> </span>
            <div class="flex gap-2 justify-between min-w-[20rem]">

              <.live_component module={EveIndustrexWeb.Common.MiniMarket} selected_order={Enum.filter([@total_list], fn tl -> tl.type_id == @product.product_type_id end)}
              reaction_product_id={@id} material_cost_id={~s"#{@id}_#{@product.product_type_id}_material_cost"} category={:reaction_product} id={~s"#{@id}_#{@product.product_type_id}"} orders={Enum.filter(@orders.result, fn o -> o.type_id == @product.product_type_id end)} item={%{:name => @product.product.name, :type_id => @product.product_type_id}} amount={@product.amount}/>
              <.live_component module={EveIndustrexWeb.Alchemy.MaterialCost} category={:product} id={~s"#{@id}_#{@product.product_type_id}_material_cost"} amount={@product.amount}/>
            </div>
          </div>

      <% end %>
          <.live_component module={EveIndustrexWeb.Alchemy.Total} profit_component_id={@profit_component_id} id={@id<>"_total"} />
    </div>
    """
  end
  def render(assigns) do
    ~H"""
      <div class={"p-2 mx-auto h-6 w-6 rounded-full border-solid border-2 border-[white_transparent_white_transparent] animate-spin"}/>
    """
  end
end
