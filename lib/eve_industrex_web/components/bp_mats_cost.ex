defmodule EveIndustrexWeb.Common.BpMatsCost do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component

  def update_component(cid, %{:update => data}) do
    send_update(__MODULE__, id: cid, update: data)
  end

  def update(%{:update => %{:show_modal => boolean}}, socket) do

    {:ok, socket |> assign(:show_modal, boolean)}
  end
  def update(assigns, socket) do


      {:ok, socket |> assign(assigns) |> assign(:show_modal, false) }
  end

  def render(assigns) do
    ~H"""
    <div class="">
      <%= if Enum.any?(@bp_materials, fn bpm -> bpm.order == :missing_order end) do %>
      <div phx-click={"toggle_modal"} phx-target={@myself} class={"cursor-pointer hover:text-white hover:bg-black transition p-1 flex flex-col justify-center bg-red-500 animate-pulse text-white"}>
        <span class="text-center">N/A - missing prices</span>
      </div>
    <% else %>
        <div phx-click={"toggle_modal"} phx-target={@myself} class={"cursor-pointer hover:text-white hover:bg-black transition p-1 flex flex-col justify-center"}>
          <%= if @runs == 1 do %>
            <span class="text-center">  <%= Utils.format_with_coma(List.foldl(@bp_materials, 0, fn x, acc -> if x == 0, do: 0, else: x.order.price * x.amount + acc end))<>" ISK" %> </span>
          <% else %>
            <span class="text-center">  <%= Utils.format_with_coma(List.foldl(@bp_materials, 0, fn x, acc -> if x == 0, do: 0, else: x.order.price * x.amount + acc end))<>" ISK per run" %> </span>
            <span class="text-center">  <%= Utils.format_with_coma(List.foldl(@bp_materials, 0, fn x, acc -> if x == 0, do: 0, else: x.order.price * x.amount + acc end) * @runs)<>" ISK total" %> </span>
          <% end %>
      </div>
      <% end %>

      <%= if @show_modal do %>

        <.modal show={@show_modal} id={~s"modal_#{@id}"} on_cancel={JS.push("close_modal", target: @myself)}>
        <%= if Map.has_key?(assigns, :production_product) do %>
          <span class="pb-4 text-lg font-semibold"> <%= @production_product %> </span>
        <% end %>
          <%= for m <- @bp_materials do %>
          <div class="p-1 flex gap-2 items-center justify-between">
            <div class="w-[50%] flex justify-between">
              <span> <%= m.name %> </span>
              <span> <%= m.amount %> </span>

            </div>
            <.live_component module={EveIndustrexWeb.Common.MiniMarket} tax_rate={@tax_rate} category={:bp_materials} amount={m.amount} id={@id<>"_#{m.type_id}_MiniMarket_BP_Materials"} selected_order={m.order} selected_trade_hub={@selected_trade_hub} item={%{:type_id => m.type_id, :category_id => m.category_id, :name => m.name}} offer_id={@offer_id}/>

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
