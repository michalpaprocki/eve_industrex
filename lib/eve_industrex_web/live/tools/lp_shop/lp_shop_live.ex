defmodule EveIndustrexWeb.Tools.LpShopLive do

alias EveIndustrex.Universe
alias EveIndustrex.Market
alias EveIndustrex.Utils
alias EveIndustrexWeb.Layouts
alias Phoenix.LiveView.AsyncResult
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Corporation

  @form_types %{tax_rate: :float, selected_corp: :integer, selected_trade_hub: :integer}
  def mount(_params, _session, socket) do
    corps = Corporation.get_npc_corps_names_and_ids()
    hubs =  Universe.get_trade_hubs()

    params = %{"selected_corp" => nil, "selected_trade_hub" => Enum.at(hubs,3).station_id}
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    {:ok, socket
     |> assign(:corps, corps)
     |> assign(:selected_corp, nil)
     |> assign(:offers, nil)
     |> assign(:tax_rate, 0.0)
     |> assign(:form, to_form(changeset, as: :lp_shop_form))
     |> assign(:hubs, hubs) , layout: {Layouts, :lp_shop}
    }
  end

  def render(assigns) do
    ~H"""
    <section>
    <span><%= hd(Enum.filter(@hubs, fn h -> h.station_id == @form[:selected_trade_hub].value end )).name %></span>
      <h1 class="text-xl font-semibold mb-10"><%= if @form[:selected_corp].value != nil, do:  hd(Enum.filter(@corps, fn c -> c.corp_id == @form[:selected_corp].value end)).name %> Loyalty Points Shop</h1>
      <div class="flex">
      <.form for={@form} id={"lp_shop_form"} phx-change={"validate_form"} class="p-4 flex gap-4">
        <div class="flex flex-col gap-2">
          <.input field={@form[:selected_corp]} label="Corporation Select" prompt={"Select Corporation..."} type={"select"} options={Enum.map(@corps, fn c -> [key: c.name, value: c.corp_id] end)} name="corp selection" id={"corp_select"} class="mt-0 text-base"/>
        </div>
          <div class={""}>
            <.input class="" value={@form[:selected_trade_hub].value} field={@form[:selected_trade_hub]} options={Enum.map(@hubs, fn h -> [key: h.name, value: h.station_id] end)}  label="Trade Hub:" type={"select"} name="trade hub select" id={"trade_hub_selection"}/>
          </div>
          <.button phx-disable-with="Saving..." disabled={true} class={"hidden"}>
                submit
          </.button>
      </.form>
      <.live_component id={"tax_input"} module={EveIndustrexWeb.Common.TaxRate} />
      </div>
      <div class="flex flex-col gap-2">
      <%= cond do %>
        <%  @offers == nil -> %>
          <% nil %>
        <% @offers.loading || @orders.loading -> %>
         <div class="text-center text-xl font-bold my-20">
            Loading ...
            <div class={"mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
          </div>
        <% @offers.ok? -> %>

          <%= for {o, i} <- Enum.with_index(@offers.result) do %>
          <div class="flex gap-2 justify-between p-2 ring-2 ring-black/80 rounded-md ">
            <div class="flex flex-col justify-between items-start w-[15%]">
              <div class="flex flex-col">
                <span><%= o.type.name %></span>
                <span> <%= if String.contains?(o.type.name, "Blueprint"), do: "Runs: #{o.quantity}", else: "Amount: #{o.quantity}"  %></span>
              </div>

              <div class="flex flex-col justify-center">
                <%= if String.contains?(o.type.name, "Blueprint") do %>
                  <%= Enum.map(o.type.bp_products, fn bpp -> "Portion size #{bpp.portion_size}"  end) %>
                  <%= for bpp <-o.type.bp_products do %>
                      <.live_component module={EveIndustrexWeb.Common.MiniMarket} category={:product} isk_per_lp_id={Integer.to_string(i)<>"_#{o.type.type_id}_ISK_per_LP"} id={Integer.to_string(i)<>"_#{o.type.type_id}_MiniMarket_Product"} item={%{:name => bpp.name, :type_id => bpp.type_id}} orders={Enum.filter(@orders.result, fn order -> order.type_id == bpp.type_id  end)} />
                  <% end %>
                <% else %>
                  <.live_component module={EveIndustrexWeb.Common.MiniMarket} category={:product} isk_per_lp_id={Integer.to_string(i)<>"_#{o.type.type_id}_ISK_per_LP"} id={Integer.to_string(i)<>"_#{o.type.type_id}_MiniMarket_Product"} item={%{:name => o.type.name, :type_id => o.type.type_id}} orders={Enum.filter(@orders.result, fn order -> order.type_id == o.type.type_id end)}  />
                <% end %>
              </div>
            </div>

            <div class="flex flex-col gap-1 min-w-[10%]">
              <span>isk cost: <%= Utils.format_with_coma(o.isk_cost) %></span>
              <span>lp cost: <%= Utils.format_with_coma(o.lp_cost) %></span>
            </div>

            <div  class="flex flex-col">
              <%= for ri <-o.req_items do %>
                <div class="flex gap-2 min-w-[20%] justify-between">
                <%= if ri != nil do %>
                  <div class="p-1">
                    <span> <%= ri.type.name %></span>
                    <span> <%= ri.quantity%></span>
                  </div>
                  <.live_component module={EveIndustrexWeb.Common.MiniMarket} amount={ri.quantity} category={:materials} isk_per_lp_id={Integer.to_string(i)<>"_#{o.type.type_id}_ISK_per_LP"} id={Integer.to_string(i)<>"_#{ri.type_id}_MiniMarket_Materials"} item={%{:name =>ri.type.name, :type_id => ri.type.type_id}} orders={Enum.filter(@orders.result, fn order -> order.type_id == ri.type_id end)} />
                <% end %>
                </div>
              <% end %>
            </div>
            <div>
              <%= if String.contains?(o.type.name, "Blueprint") do %>

                <.live_component module={EveIndustrexWeb.Common.BpMatsCost} isk_per_lp_id={Integer.to_string(i)<>"_#{o.type.type_id}_ISK_per_LP"} id={Integer.to_string(i)<>"_#{o.type.type_id}_BP_Mats_Cost"} bp_materials={o.type.products} orders={@orders.result} production_product={o.type.name} runs={o.quantity}/>
              <% end %>
            </div>

            <div class="flex flex-col min-w-[15%]">
            <%!-- refactor to allow sorting by isk / lp --%>
              <%= if String.contains?(o.type.name, "Blueprint") do %>
                <.live_component module={EveIndustrexWeb.LpShop.IskOnLpReturn} id={Integer.to_string(i)<>"_#{o.type.type_id}_ISK_per_LP"} amount={o.quantity} portion_size={List.foldl(Enum.map(o.type.bp_products, fn bpp -> bpp.portion_size end), 0, fn x, acc -> acc + x end)} lp_cost={o.lp_cost} isk_cost={o.isk_cost}/>
              <% else %>
                <.live_component module={EveIndustrexWeb.LpShop.IskOnLpReturn} id={Integer.to_string(i)<>"_#{o.type.type_id}_ISK_per_LP"} amount={o.quantity} lp_cost={o.lp_cost} isk_cost={o.isk_cost}/>
              <% end %>
            </div>
          </div>
          <% end %>
        <% true -> %>

      <% end %>
      </div>
    </section>
    """
  end

  def handle_async(:get_orders, {:ok, result}, socket) do
    {:noreply, socket |> assign(:orders, AsyncResult.ok(result))}
  end
  def handle_async(:get_lp_offers, {:ok, result}, socket) do
    trade_hub_id = socket.assigns.form[:selected_trade_hub].value
    sorted = Enum.sort(result, &(&1.type.name < &2.type.name))
    bp_type_ids = Enum.filter(result, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.bp_products, fn bpp -> bpp.type_id end) end)
    mats_type_ids = Enum.filter(result, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.products, fn p -> p.material_type_id end) end)
    type_ids = [[[Enum.map(sorted, fn s ->  Enum.map(s.req_items, fn ri -> ri.type_id end)end) | Enum.map(sorted, &(&1.type.type_id))]|
    bp_type_ids]| mats_type_ids] |> List.flatten() |> Enum.uniq()

    orders = Task.Supervisor.async(EveIndustrex.TaskSupervisor, fn -> Market.get_market_orders_by_type_and_station(type_ids, trade_hub_id) end) |> Task.await()
    {:noreply, socket |> assign(:offers, AsyncResult.ok(sorted)) |> assign(:orders, %{:result => orders, :loading => false})}
  end

  def handle_event("validate_form",%{"_target" => ["corp selection"], "corp selection" => corp_id,} = _params, socket) do
    %{:form => form} = socket.assigns
    params = %{selected_corp: String.to_integer(corp_id), selected_trade_hub: form[:selected_trade_hub].value}

    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:selected_corp)
    |> Map.put(:action, :validate)
      {:noreply, socket |> assign(:offers, AsyncResult.loading()) |> start_async(:get_lp_offers, fn -> Corporation.get_corp_lp_offers(corp_id) end) |> assign(:form, to_form(changeset, as: :lp_shop_form))}

  end
  def handle_event("validate_form", %{"_target" => ["trade hub select"],"trade hub select" => station_id} = _params, socket) do
    %{:form => form, :offers => offers} =socket.assigns
    params = %{selected_corp: form[:selected_corp].value, selected_trade_hub: station_id}
    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:selected_trade_hub)
    |> Map.put(:action, :validate)

    if params.selected_trade_hub != nil && offers != nil && Map.has_key?(offers, :result) do

      {:noreply, socket |> assign(:orders, AsyncResult.loading()) |> start_async(:get_orders, fn -> get_new_orders(offers.result, params.selected_trade_hub) end)  |> assign(:form, to_form(changeset, as: :lp_shop_form))}
    else
      {:noreply, socket |> assign(:form, to_form(changeset, as: :lp_shop_form))}
    end
  end
  def handle_info({:new_tax_rate, tax_rate}, socket) do

    %{:offers => offers} = socket.assigns
    if offers == nil || !Map.has_key?(offers, :result) || !Map.has_key?(offers, :result) && offers.result == nil do
      {:noreply, socket |> assign(:tax_rate, tax_rate)}
    else

      product_components_ids = Enum.map(Enum.with_index(offers.result), fn {o, i} ->
        if String.contains?(o.type.name, "Blueprint") do
          Enum.map(o.type.bp_products, fn _bpp -> Integer.to_string(i)<>"_#{o.type.type_id}" end)
        else
          Integer.to_string(i)<>"_#{o.type.type_id}"
        end
      end)  |> List.flatten()
      Enum.map(product_components_ids, fn pci ->
        EveIndustrexWeb.Common.MiniMarket.update_component(pci<>"_MiniMarket_Product", %{:update => %{:tax_rate => tax_rate}})
        EveIndustrexWeb.LpShop.IskOnLpReturn.update_component(pci<>"_ISK_per_LP", %{:update => %{:tax_rate => tax_rate}})
      end)
      {:noreply, socket |> assign(:tax_rate, tax_rate)}
    end
  end
  def handle_info({:get_tax_rate, module, cid}, socket) do

      send_update(module, id: cid, update: %{:tax_rate => socket.assigns.tax_rate})
    {:noreply, socket}
  end

  defp get_new_orders(offers, trade_hub_id) do
    bp_type_ids = Enum.filter(offers, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.bp_products, fn bpp -> bpp.type_id end) end)
    mats_type_ids = Enum.filter(offers, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.products, fn p -> p.material_type_id end) end)
    type_ids = [[[Enum.map(offers, fn s ->  Enum.map(s.req_items, fn ri -> ri.type_id end)end) | Enum.map(offers, &(&1.type.type_id))]|
    bp_type_ids]| mats_type_ids] |> List.flatten() |> Enum.uniq()
    Market.get_market_orders_by_type_and_station(type_ids, trade_hub_id)
  end

end
