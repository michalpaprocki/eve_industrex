defmodule EveIndustrexWeb.LpShop.LpBpMaterials do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component

  def update_component(cid, %{:update => data}) do
    send_update(__MODULE__, id: cid, update: data)
  end


  def update(assigns, socket) do
    %{:bp_material_prices => bp_material_prices} = assigns
      all_present =
        Enum.all?(bp_material_prices, fn {_type_id, price} ->
          if price != nil do
            true
          else
            false
          end
        end)





    {:ok, socket |> assign(assigns) |> assign(:show_modal, false) |> assign(:all_present,  all_present) }
  end

 def render(assigns) do

    ~H"""
    <div class="">
      <%= if !@all_present do %>
      <div phx-click={"toggle_modal"} phx-target={@myself} class={"cursor-pointer hover:text-white hover:bg-black transition p-1 flex flex-col justify-center bg-red-500 animate-pulse text-white"}>
        <span class="text-center">N/A - missing prices</span>
      </div>
    <% else %>
        <div phx-click={"toggle_modal"} phx-target={@myself} class={"cursor-pointer hover:text-white hover:bg-black transition p-1 flex flex-col justify-center"}>
          <%= if @runs == 1 do %>
            <span class="text-center font-bold">  <%= Utils.format_with_coma(calc_total(@bp_materials , @bp_material_prices))<>" ISK" %> </span>
          <% else %>
            <span class="text-center font-semibold">  <%= Utils.format_with_coma(calc_total(@bp_materials , @bp_material_prices))<>" ISK per run" %> </span>
            <span class="text-center font-bold">  <%= Utils.format_with_coma(calc_total(@bp_materials , @bp_material_prices) * @runs)<>" ISK total" %> </span>
          <% end %>
      </div>
      <% end %>

      <%= if @show_modal do %>

        <.modal show={@show_modal} id={~s"modal_#{@id}"} on_cancel={JS.push("close_modal", target: @myself)}>
        <%= if Map.has_key?(assigns, :production_product) do %>
          <span class="pb-4 text-lg font-semibold text-white"> <%= @production_product %> </span>
        <% end %>
          <%= for m <- @bp_materials do %>
          <div class="p-1 flex gap-2 items-center justify-between text-white">
            <div class="w-[50%] flex justify-between">
              <span> <%= m.name %> </span>
              <span> <%= m.quantity %> </span>

            </div>
            <.live_component module={EveIndustrexWeb.LpShop.LpMiniMarket} category={:bp_materials} amount={m.quantity} id={@id<>"_#{m.type_id}_MiniMarket_BP_Materials"} selected_trade_hub={@selected_trade_hub} item={%{:type_id => m.type_id, :category_id => m.category_id, :name => m.name, :price => @bp_material_prices[m.type_id]}} order_type={@order_type} offer_id={@offer_id}/>

          </div>
          <% end %>
        </.modal>
      <% end %>
    </div>
    """
  end
   def handle_event("toggle_modal", %{}, socket) do
    {:noreply, socket |> assign(:show_modal,!socket.assigns.show_modal)}
  end
  def handle_event("close_modal", %{}, socket) do
    {:noreply, socket |> assign(:show_modal, false)}
  end

  defp calc_total(bp_materials, prices) do
    List.foldl(bp_materials, 0, fn x, acc -> if x == 0, do: 0, else: Map.get(prices,  x.type_id) * x.quantity + acc end)

  end

end
