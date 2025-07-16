defmodule EveIndustrexWeb.Common.BpMatsCost do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component

  def update_component(cid, %{:update => data}) do
    send_update(__MODULE__, id: cid, update: data)
  end
  def update(%{:update => %{:material_cost => material}}, socket) do

    %{:total_list => prev_total} = socket.assigns
    total_list = Enum.map(prev_total,fn pt -> if pt.type_id == material.type_id, do: %{:type_id => pt.type_id, :id => material.id, :amount => pt.amount, :price => material.price} , else: pt end)

    if Enum.any?(total_list, fn tl -> tl.price == nil end) do
      {:ok, socket |> assign(:total_list, total_list)}
    else

      total = List.foldl(total_list ,0, fn x, acc -> acc + x.price * x.amount end)
      EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(socket.assigns.isk_per_lp_id, %{:update => %{:total_bp_materials_cost => total}})

      {:ok, socket |> assign(:total_list, total_list) |> assign(:total, total)}
    end
  end
  def update(%{:update => %{:show_modal => boolean}}, socket) do

    {:ok, socket |> assign(:show_modal, boolean)}
  end
  def update(assigns, socket) do
    amounts_and_orders = Enum.map(assigns.bp_materials, fn bpm -> %{:amount => bpm.amount, :type_id => bpm.material_type_id, :orders => Enum.filter(assigns.orders, fn o -> o.type_id == bpm.material_type_id end) |> Enum.filter(fn o -> o.is_buy_order == false end)} end)

    total_list = Enum.map(amounts_and_orders, fn aao -> if length(aao.orders) > 0 , do: %{:type_id => aao.type_id, :price => hd(aao.orders).price , :amount =>  aao.amount, :id => hd(aao.orders).order_id}, else: %{:type_id => aao.type_id, :price => nil , :amount =>  aao.amount, :id => nil} end)

    if Enum.any?(total_list, fn tl -> tl.id == nil end) do

      total = nil
      EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(assigns.isk_per_lp_id, %{:update => %{:total_bp_materials_cost => total}})
      {:ok, socket |> assign(assigns) |> assign(:show_modal, false) |> assign(:total_list, total_list) |> assign(:total, total)}

    else

      total = List.foldl(total_list, 0, fn x, acc -> acc + x.price * x.amount end)
      EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(assigns.isk_per_lp_id, %{:update => %{:total_bp_materials_cost => total}})
      {:ok, socket |> assign(assigns) |> assign(:show_modal, false) |> assign(:total_list, total_list) |> assign(:total, total)}

    end

  end

  def render(assigns) do
    ~H"""
    <div class="">
      <div phx-click={"toggle_modal"} phx-target={@myself} class={"cursor-pointer hover:text-white hover:bg-black transition p-1 flex flex-col justify-center #{if @total == nil, do: "bg-red-500 animate-pulse text-white"}"}>
      <span>Production Materials Cost:</span>
      <span class="text-center">  <%= if @total != nil, do: Utils.format_with_coma(@total)<>" ISK" , else: "N/A - missing prices" %> </span>
      </div>
      <%= if @show_modal do %>

        <.modal show={@show_modal} id={~s"modal_#{@id}"} on_cancel={JS.push("close_modal", target: @myself)}>
        <%= if Map.has_key?(assigns, :production_product) do %>
          <span class="pb-4 text-lg font-semibold"> <%= @production_product %> </span>
        <% end %>
          <%= for m <- @bp_materials do %>
          <div class="p-1 flex gap-2 items-center justify-between">
          <div class="w-[50%] flex justify-between">
            <span> <%= m.material_type.name %> </span>
            <span> <%= m.amount %> </span>

          </div>
              <.live_component module={EveIndustrexWeb.Common.MiniMarket} category={:bp_materials} bp_materials_cost_id={@id} amount={m.amount} product={false} id={@id<>"_#{m.material_type_id}_MiniMarket_BP_Materials"} item={%{:name => m.material_type.name, :type_id => m.material_type.type_id}} orders={Enum.filter(@orders, fn order -> order.type_id == m.material_type_id end)} selected_order={Enum.filter(@total_list, fn tl -> tl.type_id == m.material_type.type_id end)}/>

          </div>
          <% end %>
        </.modal>
      <% end %>
    </div>
    """
  end
   def handle_event("toggle_modal", %{}, socket) do
    update_component(socket.assigns.id, %{:update => %{:show_modal => !socket.assigns.show_modal}})
    {:noreply, socket}
  end
  def handle_event("close_modal", %{}, socket) do
    update_component(socket.assigns.id, %{:update => %{:show_modal => false}})
    {:noreply, socket}
  end
end
