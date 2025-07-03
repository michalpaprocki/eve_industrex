defmodule EveIndustrexWeb.Market.MiniMarket do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  @types ["SELL", "BUY"]
  def update_component(cid, %{:show_modal => boolean}) do
    send_update(__MODULE__, id: cid, update: %{:show_modal => boolean})
  end
  def update(%{:update => %{:show_modal => boolean}}, socket) do
    {:ok, socket  |> assign(:show_modal, boolean)}
  end
  def update(assigns, socket) do

    filtered = Enum.filter(List.flatten(Enum.sort(assigns.orders, &(&1.price <= &2.price))), fn o -> o.is_buy_order == false end)
    selected_order = if filtered == [], do: nil, else: hd(filtered).price
    EveIndustrexWeb.Alchemy.MaterialCost.update_component(assigns.id<>"_material_cost", %{:selected_price => selected_order})
    {:ok, socket |> assign(assigns) |> assign(:show_modal, false) |> assign(:selected_price, selected_order) |> assign(:types, @types) |> assign(:selected_type, hd(@types))}
  end

  def render(assigns) do
    ~H"""
      <div class="p-1">
        <span phx-target={@myself} phx-click="toggle_modal" class={"cursor-pointer hover:text-white hover:bg-black transition p-1 #{if @selected_price == nil, do: "bg-red-500 animate-pulse text-white"}"}>
          <%= if @selected_price == nil, do: ~s"no #{@selected_type} orders", else: Utils.format_with_coma(@selected_price)<>" ISK" %>
        </span>
        <%= if @show_modal do %>
         <.modal show={@show_modal} id={~s"modal_#{@id}"} on_cancel={JS.push("close_modal", target: @myself)}>
          <div class="">
            <%= @item %>
            <div class="flex flex-col gap-2 py-4">
              <div>
              custom price
              </div>
              <.label class="" for={"order_type"}>Order Type</.label>
              <select class="rounded-md" id="order_type">
                <%= for t <- @types do %>
                  <option selected={if @selected_type == t, do: true} phx-target={@myself} phx-click="select_type" value={t}><%= t%></option>
                <% end %>
              </select>
            </div>
          </div>
          <div class="h-[50vh] overflow-auto">
            <table class={"w-full text-sm table-fixed border-collapse"}>
              <thead>
                <tr class="">
                  <th class=" w-[10%] sticky top-0 bg-stone-200"> volume </th>
                  <th class=" w-[12%] sticky top-0 bg-stone-200"> price </th>
                  <th class=" w-[20%] sticky top-0 bg-stone-200"> location </th>
                </tr>
              </thead>
              <tbody class="">
              <%= Enum.map(Enum.sort(Enum.filter(@orders, fn f -> if @selected_type == hd(@types), do: f.is_buy_order == false, else: f.is_buy_order == true end), (if @selected_type == hd(@types), do: &(&1.price <= &2.price), else: &(&1.price >= &2.price))), fn o -> %>

              <tr class="px-2 font-sm hover:bg-black hover:text-white" phx-target={@myself} phx-click={"select_price"} phx-value-price={o.price}>
                <td class="pl-2 text-end"> <%= Utils.format_with_coma(o.volume_remain) %> / <%= Utils.format_with_coma(o.volume_total) %> </td>
                <td class="pl-2 text-end truncate"> <%= Utils.format_with_coma(o.price) %> &nbsp;ISK </td>
                <td class="pl-2 text-start truncate">  <span class={apply_color_on_status(:erlang.float_to_binary(o.station.system.security_status, [decimals: 1]))}><%= :erlang.float_to_binary(o.station.system.security_status, [decimals: 1]) %></span>&nbsp;<%= o.station.name %> </td>
              </tr>
              <% end) %>
              </tbody>
            </table>
            </div>
          </.modal>
        <% end %>
      </div>
    """
  end
  def handle_event("toggle_modal", %{}, socket) do
    update_component(socket.assigns.id, %{:show_modal => !socket.assigns.show_modal})
    {:noreply, socket}
  end
  def handle_event("close_modal", %{}, socket) do
    update_component(socket.assigns.id, %{:show_modal => false})
    {:noreply, socket}
  end
  def handle_event("select_price", %{"price" => price}, socket) do
    EveIndustrexWeb.Alchemy.MaterialCost.update_component(socket.assigns.id<>"_material_cost", %{:selected_price => String.to_float(price)})
    {:noreply, socket |> assign(:selected_price, String.to_float(price)) |> assign(:show_modal, false)}
  end
  def handle_event("select_type", %{"value" => value}, socket) do
    {:noreply, socket |> assign(:selected_type, value)}
  end
  # not sure why but this wont work when called from another module
  defp apply_color_on_status(sec_status) do
    case sec_status do
      "1.0" ->
        "text-system1.0"
      "0.9" ->
        "text-system0.9"
      "0.8" ->
        "text-system0.8"
      "0.7" ->
        "text-system0.7"
      "0.6" ->
        "text-system0.6"
      "0.5" ->
        "text-system0.5"
      "0.4" ->
        "text-system0.4"
      "0.3" ->
        "text-system0.3"
      "0.2" ->
        "text-system0.2"
      "0.1" ->
        "text-system0.1"
      _ ->
        "text-system0.0"
    end
  end
end
