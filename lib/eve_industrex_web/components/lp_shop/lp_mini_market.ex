defmodule EveIndustrexWeb.LpShop.LpMiniMarket do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  alias EveIndustrex.Market
  @types ["SELL", "BUY"]
  @form_types %{custom_price: :float, order_type: :string}
  def update_component(cid, %{:update => data}) do
    send_update(__MODULE__, id: cid, update: data)
  end
  def update(%{:update => %{:tax_rate => tax_rate}}, socket) do
    {:ok, socket |> assign(:updated_tax_rate, tax_rate)}
  end

  def update(assigns, socket) do

    params = %{"custom_price" => 0.00, "order_type" => get_order_type(assigns.order_type, assigns.category)}
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    selected_order = %{:id => nil, :price => assigns.item.price}


    {:ok, socket |> assign(:orders_fetched, false)|> assign(:is_loading?, false) |> assign(:form, to_form(changeset, as: :order_form)) |> assign(assigns) |> assign(:show_modal, false) |> assign(:selected_order, selected_order) |> assign(:types, @types) |> assign(:selected_type, hd(@types)) |> assign(:updated_tax_rate, nil)}
  end

  def render(assigns) do
    ~H"""
     <div class="p-1">
       <%= cond do %>
          <% @selected_order.price == nil -> %>
            <span phx-target={@myself} phx-click="toggle_modal" class={"cursor-pointer hover:text-white hover:bg-black transition p-1 bg-red-500 animate-pulse text-white"}>
              no <%= get_order_type(@order_type, @category) %> orders
            </span>
          <% true -> %>
            <span phx-target={@myself} phx-click="toggle_modal" class={"cursor-pointer hover:text-white hover:bg-black transition p-1 font-semibold"}>
              <%= Utils.format_with_coma(@selected_order.price)<>" ISK"%>
            </span>
        <% end %>
        <%= if @show_modal do %>
         <.modal show={@show_modal} id={~s"modal_#{@id}"} on_cancel={JS.push("close_modal", target: @myself)}>
          <div class="flex flex-col gap-2 pb-10">
            <div class="flex gap-2">
            <%= if String.contains?(String.downcase(@item.name), "blueprint") do %>
              <%= case @item.category_id do%>
                  <% 91 -> %>
                    <%= nil %>
                  <% _ -> %>
                    <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{@item.type_id}/icon?size=128"} />
              <% end %>
              <span class="font-semibold">
                <%= String.slice(@item.name, 0..-11//1) %>
              </span>
            <% else %>
              <%= case @item.category_id do%>
                <% 91 -> %>
                  <%= nil %>
                <% _ -> %>
                  <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{@item.type_id}/icon?size=128"} />
             <% end %>
              <span class="text-white font-semibold">
                <%= @item.name %>
              </span>
          <% end %>
            </div>
            <div class={"#{if @is_loading? == true, do: "hidden"} flex flex-col gap-2 py-4"}>
              <.form for={@form} phx-target={@myself} phx-change={"validate"}>
                <div class="flex gap-4 items-end">
                <.input field={@form[:custom_price]} name="custom price" type="number" label="Custom Price:" min="0.00" step="0.01" value={if length(@form[:custom_price].errors) == 0, do: Utils.format_with_coma(@form[:custom_price].value), else: 0.0}/>
                <.button phx-target={@myself} phx-click={"apply_price"} type="button" class="h-fit">
                  Apply
                </.button>
                </div>
                <.input class="text-black" field={@form[:order_type]} name="order type" type="select" label="Order Type" options={Enum.map(@types, fn t -> t end) }/>

                <.button phx-disable-with="Saving..." disabled={true} class={"hidden"}>
                  submit
                </.button>
              </.form>
            </div>
          </div>

          <div class={"#{if @is_loading? == true, do: "hidden"} h-[50vh] overflow-auto"}>
            <table class={"w-full text-sm table-fixed border-collapse"}>
              <thead>
                <tr class="text-black">
                  <th class=" w-[10%] sticky top-0 bg-stone-200"> volume </th>
                  <th class=" w-[12%] sticky top-0 bg-stone-200"> price </th>
                  <th class=" w-[20%] sticky top-0 bg-stone-200"> location </th>
                </tr>
              </thead>
              <tbody class="">
            <%= if @is_loading? == false do %>

              <%= Enum.map(get_order_on_type(@orders, @order_type, @category), fn o -> %>

              <tr class={"px-2 text-white font-sm #{if @selected_order.id == o.order_id, do: "bg-black text-white", else: " hover:bg-black hover:text-white cursor-pointer"}"} phx-target={@myself} phx-click={"select_order"} phx-value-price={o.price} phx-value-order_id={o.order_id}>
                <td class="pl-2 text-end"> <%= Utils.format_with_coma(o.volume_remain) %> / <%= Utils.format_with_coma(o.volume_total) %> </td>
                <td class="pl-2 text-end truncate"> <%= Utils.format_with_coma(o.price) %> &nbsp;ISK </td>
                <td class="pl-2 text-start truncate">  <span class={apply_color_on_status(:erlang.float_to_binary(o.location.security_status, [decimals: 1]))}><%= :erlang.float_to_binary(o.location.security_status, [decimals: 1]) %></span>&nbsp;<%= o.location.name %> </td>
              </tr>
              <% end) %>
            <% end %>
              </tbody>
            </table>
            </div>
            <div class={"#{if @is_loading? == true, do: "flex", else: "hidden"} flex-col items-center gap-5 mt-10"}>
                 <div class={"p-2 mx-auto h-10 w-10 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
                 <span class="text-xl font-semibold">Loading market orders...</span>
            </div>
          </.modal>
        <% end %>
      </div>

    """
  end

  def handle_event("toggle_modal", %{}, socket) do

     %{:orders_fetched => orders_fetched, :selected_trade_hub => selected_trade_hub, :item => item ,:show_modal => show_modal} = socket.assigns
    if !orders_fetched do


      {:noreply, socket |> assign(:show_modal, !show_modal) |> assign(:is_loading?, true) |> start_async(:get_market_orders, fn -> Market.Service.get_mini_market_view(selected_trade_hub, item.type_id) end) |> assign(:orders, [])}
    else

      {:noreply, socket |> assign(:show_modal, !show_modal)}
    end
  end
  def handle_event("close_modal", %{}, socket) do

    {:noreply, socket |> assign(:show_modal, false)}
  end
  def handle_event("select_type", %{"value" => value}, socket) do

    {:noreply, socket |> assign(:selected_type, value)}
  end

  def handle_event("validate", %{"_target" => ["custom price"], "custom price" => price, "order type" => _order_type} = _params, socket) do

    %{:form => form} = socket.assigns
    params = %{custom_price: price, order_type: form[:order_type].value}

    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:custom_price)
    |> Ecto.Changeset.validate_number(:custom_price, greater_than: 0)
    |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:form, to_form(changeset, as: :order_form))}
  end
  def handle_event("validate", %{"_target" => ["order type"], "custom price" => _price, "order type" => order_type} = _params, socket) do
    %{:form => form} = socket.assigns
    params = %{custom_price: form[:custom_price].value, order_type: order_type}
    order_type =
      if order_type == "SELL" do
        "sell_orders"
      else
        "buy_orders"
      end
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:order_type)
    |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:form, to_form(changeset, as: :order_form)) |> assign(:order_type, order_type)}
  end
  def handle_event("select_order", %{"price" => price, "order_id" => order_id} = _params, socket) do
    selected_order = %{:id => String.to_integer(order_id), :price => String.to_float(price)}

    case socket.assigns.category do
      :product ->

        send(self(), {:update_price, :product, %{offer_id: socket.assigns.offer_id, price: String.to_float(price), type_id: socket.assigns.item.type_id}})
      :req_item ->
        send(self(), {:update_price, :req_item, %{offer_id: socket.assigns.offer_id, price: String.to_float(price), type_id: socket.assigns.item.type_id}})
      :bp_materials ->
        send(self(), {:update_price, :bp_materials, %{offer_id: socket.assigns.offer_id, price: String.to_float(price), type_id: socket.assigns.item.type_id}})
      _->
        :noop
    end
    {:noreply, socket |> assign(:selected_order, selected_order) |> assign(:show_modal, false)}
  end
  def handle_event("apply_price", %{"value" => ""} = _params, socket) do
    %{:form => form} = socket.assigns
    if length(form.errors) == 0 do

      selected_order = %{:price => form[:custom_price].value, :id => nil, :type_id => socket.assigns.item.type_id}

      case socket.assigns.category do
        :product ->

          send(self(), {:update_price, :product, %{offer_id: socket.assigns.offer_id, price: form[:custom_price].value, type_id: socket.assigns.item.type_id}})
        :req_item ->
          send(self(), {:update_price, :req_item, %{offer_id: socket.assigns.offer_id, price: form[:custom_price].value, type_id: socket.assigns.item.type_id}})
        :bp_materials ->
          send(self(), {:update_price, :bp_materials, %{offer_id: socket.assigns.offer_id, price: form[:custom_price].value, type_id: socket.assigns.item.type_id}})
        _->
          :noop
      end
      {:noreply, socket |> assign(:selected_order, selected_order) |> assign(:show_modal, false)}
    else
      {:noreply, socket}
    end
  end
  def handle_async(:get_market_orders, {:ok, result}, socket) do

    {:noreply, socket |> assign(:orders_fetched, true) |> assign(:orders, result) |> assign(:is_loading?, false)}
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

  defp get_order_type(order_type, category) do
    cond do
    order_type == "sell" and category == :req_item ->
      "SELL"
    order_type == "buy" and category == :req_item ->
      "BUY"
    order_type == "sell_buy" and category == :req_item ->
      "SELL"
    order_type == "buy_sell" and category == :req_item ->
      "BUY"
    order_type == "sell" and category == :product ->
      "SELL"
    order_type == "buy" and category == :product ->
      "BUY"
    order_type == "sell_buy" and category == :product ->
     "BUY"
    order_type == "buy_sell" and category == :product ->
      "SELL"
    order_type == "sell" and category == :bp_materials ->
      "SELL"
    order_type == "buy" and category == :bp_materials ->
      "BUY"
    order_type == "sell_buy" and category == :bp_materials ->
      "SELL"
    order_type == "buy_sell" and category == :bp_materials ->
      "BUY"
    end
  end
  defp get_order_on_type(orders, order_type, category) do
    cond do
      order_type == "sell" and category == :req_item ->
        Enum.sort(orders.sell_orders, &(&1.price <= &2.price))
      order_type == "buy" and category == :req_item ->
        Enum.sort(orders.buy_orders, &(&1.price >= &2.price))
      order_type == "sell_buy" and category == :req_item ->
        Enum.sort(orders.sell_orders, &(&1.price <= &2.price))
      order_type == "buy_sell" and category == :req_item ->
        Enum.sort(orders.buy_orders, &(&1.price >= &2.price))
      order_type == "sell" and category == :product ->
        Enum.sort(orders.sell_orders, &(&1.price <= &2.price))
      order_type == "buy_" and category == :product ->
        Enum.sort(orders.buy_orders, &(&1.price >= &2.price))
      order_type == "sell_buy" and category == :product ->
        Enum.sort(orders.buy_orders, &(&1.price >= &2.price))
      order_type == "buy_sell" and category == :product ->
        Enum.sort(orders.sell_orders, &(&1.price <= &2.price))
      order_type == "sell" and category == :bp_materials ->
        Enum.sort(orders.sell_orders, &(&1.price <= &2.price))
      order_type == "buy" and category == :bp_materials ->
        Enum.sort(orders.buy_orders, &(&1.price >= &2.price))
      order_type == "sell_buy" and category == :bp_materials ->
        Enum.sort(orders.sell_orders, &(&1.price <= &2.price))
      order_type == "buy_sell" and category == :bp_materials ->
        Enum.sort(orders.buy_orders, &(&1.price >= &2.price))
    end
  end
end
