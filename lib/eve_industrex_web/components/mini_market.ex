defmodule EveIndustrexWeb.Common.MiniMarket do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  @types ["SELL", "BUY"]

  @form_types %{custom_price: :float, order_type: :string}
  # todo_: filtering by order type

  def update_component(cid, %{:update => data}) do
    send_update(__MODULE__, id: cid, update: data)
  end

  def update(%{:update => %{:show_modal => boolean}}, socket) do
    {:ok, socket |> assign(:show_modal, boolean)}
  end
  def update(%{:update => %{:tax_rate => tax_rate}}, socket) do
    {:ok, socket |> assign(:tax_rate, tax_rate)}
  end


  def update(assigns, socket) do
    filtered = Enum.filter(List.flatten(Enum.sort(assigns.orders, &(&1.price <= &2.price))), fn o -> o.is_buy_order == false end)

    selected_order =
   case Map.has_key?(assigns, :selected_order) do
    false ->
     if filtered == [], do: %{:id => nil, :price => nil}, else: %{:id => hd(filtered).order_id, :price => hd(filtered).price}
     true ->
      hd(assigns.selected_order)
   end

    params = %{"custom_price" => 0.00, "order_type" => hd(@types)}

    send(self(), {:get_tax_rate, __MODULE__, assigns.id})
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    cond do

      Map.has_key?(assigns, :material_cost_id) && assigns.category == :reaction_product ->

        EveIndustrexWeb.Alchemy.MaterialCost.update_component(assigns.material_cost_id, %{:selected_price => selected_order.price})
        {:ok, socket |> assign(:form, to_form(changeset, as: :order_form)) |> assign(assigns) |> assign(:show_modal, false) |> assign(:selected_order, selected_order) |> assign(:types, @types) |> assign(:selected_type, hd(@types))}

      Map.has_key?(assigns, :material_cost_id) && assigns.category == :reaction_material ->

        EveIndustrexWeb.Alchemy.MaterialCost.update_component(assigns.material_cost_id, %{:selected_price => selected_order.price})
        {:ok, socket |> assign(:form, to_form(changeset, as: :order_form)) |> assign(assigns) |> assign(:show_modal, false) |> assign(:selected_order, selected_order) |> assign(:types, @types) |> assign(:selected_type, hd(@types))}

      Map.has_key?(assigns, :isk_per_lp_id) && assigns.category == :product ->

        EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(assigns.isk_per_lp_id, %{:update => %{:product_price => selected_order.price}})
        {:ok, socket |> assign(:form, to_form(changeset, as: :order_form)) |> assign(assigns) |> assign(:show_modal, false) |> assign(:selected_order, selected_order) |> assign(:types, @types) |> assign(:selected_type, hd(@types))}

      Map.has_key?(assigns, :isk_per_lp_id) && assigns.category == :materials ->

        EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(assigns.isk_per_lp_id, %{:update => %{:initial_req_item => %{:cost => selected_order.price , :amount => assigns.amount, :type_id => assigns.item.type_id}}})
        {:ok, socket |> assign(:form, to_form(changeset, as: :order_form)) |> assign(assigns) |> assign(:show_modal, false) |> assign(:selected_order, selected_order) |> assign(:types, @types) |> assign(:selected_type, hd(@types))}
      true ->

          {:ok, socket |> assign(:form, to_form(changeset, as: :order_form)) |> assign(assigns) |> assign(:show_modal, false) |> assign(:selected_order, selected_order) |> assign(:types, @types) |> assign(:selected_type, hd(@types))}


    end
  end

  def render(assigns) do

  ~H"""
      <div class="p-1">
        <%= cond do %>
          <% !Map.has_key?(assigns, :tax_rate) -> %>
            <div class={"p-2 mx-auto h-6 w-6 rounded-full border-solid border-2 border-[black_transparent_black_transparent] animate-spin"}/>
          <% @selected_order.price == nil -> %>
            <span phx-target={@myself} phx-click="toggle_modal" class={"cursor-pointer hover:text-white hover:bg-black transition p-1 bg-red-500 animate-pulse text-white"}>
              no <%= @selected_type %> orders
            </span>
          <% assigns.category == :bp_materials -> %>
            <span phx-target={@myself} phx-click="toggle_modal" class={"cursor-pointer hover:text-white hover:bg-black transition p-1"}>
                <%= Utils.format_with_coma(@selected_order.price) <>" ISK"%>
              </span>
          <% assigns.category == :reaction_material -> %>
            <span phx-target={@myself} phx-click="toggle_modal" class={"cursor-pointer hover:text-white hover:bg-black transition p-1"}>
                <%= Utils.format_with_coma(@selected_order.price) <>" ISK"%>
              </span>
          <% true -> %>
            <span phx-target={@myself} phx-click="toggle_modal" class={"cursor-pointer hover:text-white hover:bg-black transition p-1"}>
              <%= Utils.format_with_coma(@selected_order.price * ((100 - @tax_rate) / 100))<>" ISK"%>
            </span>
        <% end %>
        <%= if @show_modal do %>
         <.modal show={@show_modal} id={~s"modal_#{@id}"} on_cancel={JS.push("close_modal", target: @myself)}>
          <div class="">

          <%= if String.contains?(String.downcase(@item.name), "blueprint") do %>
            <%= String.slice(@item.name, 0..-11//1) %>
            <% else %>
            <%= @item.name %>
          <% end %>
            <div class="flex flex-col gap-2 py-4">

              <.form for={@form} phx-target={@myself} phx-change={"validate"}>
                <div class="flex gap-4 items-end">
                <.input field={@form[:custom_price]} name="custom price" type="number" label="Custom Price:" min="0.00" step="0.01" value={if length(@form[:custom_price].errors) == 0, do: Utils.format_with_coma(@form[:custom_price].value), else: 0.0}/>
                <.button phx-target={@myself} phx-click={"apply_price"} type="button" class="h-fit">
                  Apply
                </.button>
                </div>
                <.input field={@form[:order_type]} name="order type" type="select" label="Order Type" options={Enum.map(@types, fn t -> t end) }/>

                <.button phx-disable-with="Saving..." disabled={true} class={"hidden"}>
                  submit
                </.button>
              </.form>
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
              <%= Enum.map(Enum.sort(Enum.filter(@orders, fn f -> if @form[:order_type].value == hd(@types), do: f.is_buy_order == false, else: f.is_buy_order == true end), (if @form[:order_type].value == hd(@types), do: &(&1.price <= &2.price), else: &(&1.price >= &2.price))), fn o -> %>

              <tr class={"px-2 font-sm #{if @selected_order.id == o.order_id, do: "bg-black text-white", else: " hover:bg-black hover:text-white"}"} phx-target={@myself} phx-click={"select_order"} phx-value-price={o.price} phx-value-order_id={o.order_id}>
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

    update_component(socket.assigns.id, %{:update => %{:show_modal => !socket.assigns.show_modal}})
    {:noreply, socket}
  end
  def handle_event("close_modal", %{}, socket) do
    update_component(socket.assigns.id, %{:update => %{:show_modal => false}})
    {:noreply, socket}
  end
  def handle_event("select_order", %{"price" => price, "order_id" => order_id} = _params, socket) do
    selected_order = %{:id => String.to_integer(order_id), :price => String.to_float(price)}

    cond do
      Map.has_key?(socket.assigns, :reaction_product_id) && Map.has_key?(socket.assigns, :material_cost_id) && socket.assigns.category == :reaction_product ->
        EveIndustrexWeb.Alchemy.MaterialCost.update_component(socket.assigns.material_cost_id, %{:selected_price => selected_order.price})
        EveIndustrexWeb.Alchemy.Product.update_component(socket.assigns.reaction_product_id, %{:update => %{:material_cost => %{:price => selected_order.price, :amount => socket.assigns.amount, :type_id => socket.assigns.item.type_id, :id => selected_order.id}}})

      Map.has_key?(socket.assigns, :material_cost_id) && socket.assigns.category == :reaction_material ->
        EveIndustrexWeb.Alchemy.MaterialCost.update_component(socket.assigns.material_cost_id, %{:selected_price => selected_order.price})

      Map.has_key?(socket.assigns, :material_cost_id) && socket.assigns.category == :reaction_product ->

        EveIndustrexWeb.Alchemy.MaterialCost.update_component(socket.assigns.material_cost_id, %{:selected_price => selected_order.price})

      Map.has_key?(socket.assigns, :isk_per_lp_id) && socket.assigns.category == :product ->
        EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(socket.assigns.isk_per_lp_id, %{:update => %{:product_price => String.to_float(price)}})

      Map.has_key?(socket.assigns, :isk_per_lp_id) && socket.assigns.category == :materials ->
        EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(socket.assigns.isk_per_lp_id, %{:update => %{:req_item => %{:cost => selected_order.price , :amount => socket.assigns.amount, :type_id => socket.assigns.item.type_id}}})

      Map.has_key?(socket.assigns, :bp_materials_cost_id) && socket.assigns.category == :bp_materials ->
        EveIndustrexWeb.Common.BpMatsCost.update_component(socket.assigns.bp_materials_cost_id, %{:update => %{:material_cost => %{:price => selected_order.price, :amount => socket.assigns.amount, :type_id => socket.assigns.item.type_id, :id => selected_order.id}}})

      true ->
        nil
    end
    {:noreply, socket |> assign(:selected_order, selected_order) |> assign(:show_modal, false)}
  end
  def handle_event("select_type", %{"value" => value}, socket) do
    {:noreply, socket |> assign(:selected_type, value)}
  end
  def handle_event("validate", %{"_target" => ["custom price"], "custom price" => price, "order type" => _order_type} = _params, socket) do
    %{:form => form} = socket.assigns
    params = %{custom_price: price, order_type: form[:order_type].value}

    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:custom_price)
    |> Ecto.Changeset.validate_number(:custom_price, greater_than: 0)
    |> Map.put(:action, :validate)

    {:noreply, socket |> assign(:form, to_form(changeset, as: :order_form))}
  end
  def handle_event("validate", %{"_target" => ["order type"], "custom price" => _price, "order type" => order_type} = _params, socket) do
    %{:form => form} = socket.assigns
    params = %{custom_price: form[:custom_price].value, order_type: order_type}

    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:order_type)
    |> Map.put(:action, :validate)
    {:noreply, socket |> assign(:form, to_form(changeset, as: :order_form))}
  end

  def handle_event("apply_price", %{"value" => ""} = _params, socket) do
    %{:form => form} = socket.assigns
      selected_order = %{:price => form[:custom_price].value, :id => nil, :type_id => socket.assigns.item.type_id}

    cond do
      Map.has_key?(socket.assigns, :reaction_product_id) && Map.has_key?(socket.assigns, :material_cost_id) && socket.assigns.category == :reaction_product ->
          EveIndustrexWeb.Alchemy.MaterialCost.update_component(socket.assigns.material_cost_id, %{:selected_price => selected_order.price})
          EveIndustrexWeb.Alchemy.Product.update_component(socket.assigns.reaction_product_id, %{:update => %{:material_cost => %{:price => form[:custom_price].value, :amount => socket.assigns.amount, :type_id => socket.assigns.item.type_id, :id => :no_id}}})

      Map.has_key?(socket.assigns, :material_cost_id) && socket.assigns.category == :reaction_material ->
        EveIndustrexWeb.Alchemy.MaterialCost.update_component(socket.assigns.material_cost_id, %{:selected_price => selected_order.price})

      Map.has_key?(socket.assigns, :material_cost_id) && socket.assigns.category == :reaction_product ->
         EveIndustrexWeb.Alchemy.MaterialCost.update_component(socket.assigns.material_cost_id, %{:selected_price => selected_order.price})

      Map.has_key?(socket.assigns, :isk_per_lp_id) && socket.assigns.category == :product ->
        EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(socket.assigns.isk_per_lp_id, %{:update => %{:product_price => form[:custom_price].value}})

      Map.has_key?(socket.assigns, :isk_per_lp_id) && socket.assigns.category == :materials ->
        EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(socket.assigns.isk_per_lp_id, %{:update => %{:req_item => %{:cost => selected_order.price , :amount => socket.assigns.amount, :type_id => socket.assigns.item.type_id}}})

      Map.has_key?(socket.assigns, :bp_materials_cost_id) && socket.assigns.category == :bp_materials ->
        EveIndustrexWeb.Common.BpMatsCost.update_component(socket.assigns.bp_materials_cost_id, %{:update => %{:material_cost => %{:price => form[:custom_price].value, :amount => socket.assigns.amount, :type_id => socket.assigns.item.type_id, :id => :no_id}}})

      true ->
        nil
    end
    {:noreply, socket |> assign(:selected_order, selected_order) |> assign(:show_modal, false)}

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
