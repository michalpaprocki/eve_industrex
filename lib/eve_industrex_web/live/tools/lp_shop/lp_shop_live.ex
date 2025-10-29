defmodule EveIndustrexWeb.Tools.LpShopLive do

alias EveIndustrex.Universe
alias EveIndustrex.Market
alias EveIndustrex.Utils
alias EveIndustrexWeb.Layouts
alias Phoenix.LiveView.AsyncResult
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Corporation
  @form_types %{tax_rate: :float, selected_corp: :integer, selected_trade_hub: :integer, filter: :string, sort: :string}
  def mount(_params, _session, socket) do
    corps = Corporation.get_npc_corps_names_and_ids()
    hubs =  Universe.get_trade_hubs()
    params = %{"selected_corp" => nil, "selected_trade_hub" => Enum.at(hubs,3).station_id, "filter" => "", "sort" => "name"}
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    {:ok, socket
      |> assign(:corps, corps)
      |> assign(:selected_corp, nil)
      |> assign(:offers, nil)
      |> assign(:tax_rate, 0.0)
      |> assign(:form, to_form(changeset, as: :lp_shop_form))
      |> assign(:orders, [])
      |> assign(:filtered_offers, nil)
      |> assign(:sorting_options, @sorting_options)
      |> assign(:show_form, true)
      |> assign(:isk_per_lp_list, [])
      |> assign(:hubs, hubs) , layout: {Layouts, :lp_shop}
    }
  end

  def render(assigns) do

    ~H"""
    <div class="text-white font-semibold h-30 flex flex-col items-center gap-5 mt-10">
       <%= if @form[:selected_corp].value != nil do %>
        <img class="w-80 h-80 blur-sm fixed left-[50%] translate-y-[75%] -translate-x-[50%] -z-10" src={"https://images.evetech.net/corporations/#{@form[:selected_corp].value}/logo?size=256"} />
        <% end %>
      <div class="flex gap-8 flex-col top-20 left-0 w-full h-20">
        <h1 class="self-center text-2xl"><%= if @form[:selected_corp].value != nil, do: hd(Enum.filter(@corps, fn c -> c.corp_id == @form[:selected_corp].value end)).name %> Loyalty Points Shop</h1>
         <%= if Map.has_key?(assigns, :number_of_offers) do %>
        <span class="px-8 font-lg self-center"><%= @number_of_offers %> Offers Found</span>
        <% end %>
      </div>
      <div class="flex justify-evenly gap-4">
        <details class="p-4 text-base font-semibold bg-black/70 hover:bg-white hover:text-black transition rounded-md">
          <summary>Need a hint?</summary>
            You can click on a product or material price to adjust it to your liking.
        </details>
        <details class="p-4 text-base font-semibold bg-black/70 hover:bg-white hover:text-black transition rounded-md">
          <summary>Want to filter by ISK / LP?</summary>
            <ul >
              You can filter items by ISK / LP by:
              <li class="px-1">
                - using the ">" to get items that are higher than value specified e.g.: >2000 will return items with ISK / LP ratio higher than 2000.
              </li>
              <li class="px-1">
                - providing a range will filter items within it e.g.: [1000..2000] will return items with ISK / LP ratio higher than 1000 and lower than 2000.
              </li>
            </ul>
        </details>
      </div>
    </div>
        <div class={"flex w-full bg-black/70 backdrop-blur-sm top-20 left-0 sticky justify-between 2xl:justify-center transition-all shadow-sm shadow-black delay-0 duration-500 rounded-b-md z-10  #{if @show_form, do: "h-[18rem] lg:h-[8rem]", else: "h-0"}"} id={"lp_form_container"}>
          <div class="flex order-last gap-1 p-2 h-fit">
          <.button title="minimize or maximize" phx-click="toggle_form" type="button" aria-description="minimize or maximaze the form" class="z-10 top-24 h-10 w-10"> <%= if @show_form, do: "＿", else: "⬜" %> </.button>
          <.button title="scroll to top" phx-click={JS.dispatch("phx-scroll-to-top")} type="button" aria-description="scroll to top" class="z-10 top-24 h-10 w-10">▲</.button>
          </div>
          <div class="overflow-hidden flex flex-row">
            <.form for={@form} id={"lp_shop_form"} phx-change={"validate_form"} class={"p-4 z-10"}>
              <div class="flex gap-2 lg:flex-row flex-col">
                <.input field={@form[:selected_corp]} label="Corporation Select" prompt={"Select Corporation..."} type={"select"} options={Enum.map(@corps, fn c -> [key: c.name, value: c.corp_id] end)} name="corp selection" id={"corp_select"} class="mt-0 text-base"/>
                <.input class="" value={@form[:selected_trade_hub].value} field={@form[:selected_trade_hub]} options={Enum.map(@hubs, fn h -> [key: h.name, value: h.
                station_id] end)}  label="Trade Hub:" type={"select"} name="trade hub select" id={"trade_hub_selection"}/>
              <%= if @offers == nil do %>
                <%= nil %>
              <% else %>
                <div class="flex flex-row gap-2 justify-between">
                  <.input field={@form[:filter]} phx-debounce={1000} label="Search Item" type={"text"} name="filter items" class={"mt-0 text-base #{if @offers == nil , do: "cursor-not-allowed"}"} disabled={if @offers == nil , do: true, else: false} />
                  <.input field={@form[:sort]} label="Sort" type={"select"} name="sort by" class={"mt-0 text-base #{if @offers == nil , do: "cursor-not-allowed"}"} disabled={if @offers == nil , do: true, else: false} options={["name - asc", "name - desc", "isk/lp - asc", "isk/lp - desc"]} value={@form[:sort].value}/>
                </div>
              <% end %>
                <.button phx-disable-with="Saving..." disabled={true} class={"hidden"}>
                      submit
                </.button>
              </div>
            </.form>
            <.live_component id={"tax_input"} module={EveIndustrexWeb.Common.TaxRate} />
          </div>
        </div>

      <div class="flex items-center flex-col gap-2 px-4 sm:px-6 lg:px-8 mt-5 text-white 2xl:w-full max-w-[1800px]">

      <%= cond do %>
        <%  @offers == nil -> %>
          <% nil %>
        <% @offers.loading || @orders.loading -> %>
         <div class="text-center text-xl font-bold my-20">
            Loading ...
            <div class={"mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[white_transparent_white_transparent] animate-spin"}/>
          </div>
        <% @filtered_offers != nil -> %>
          <%= for {o, i} <- Enum.with_index(@filtered_offers) do %>
          <div class={"flex gap-2 justify-between p-2 ring-2 ring-black/80 rounded-md bg-black/40 w-full max-w-[1800px]"}>
            <div class="flex flex-col justify-between items-start w-[15%]">
                <div class="flex flex-col">
                  <div class="flex gap-2">
                    <%= case o.type.group.category_id do%>
                      <% 9 -> %>
                        <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{o.type.type_id}/bp?size=128"} />
                      <% 91 -> %>
                        <%= nil %>
                      <% _ -> %>
                      <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{o.type.type_id}/icon?size=128"} />
                    <% end %>
                    <span class="font-semibold"><%= o.type.name %></span>
                  </div>
                  <span> <%= if String.contains?(o.type.name, "Blueprint"), do: "Runs: #{o.quantity}", else: "Amount: #{o.quantity}"  %></span>
                </div>
              <div class="flex flex-col justify-center">
            <%= if String.contains?(o.type.name, "Blueprint") do %>
                  <%= Enum.map(o.type.bp_products, fn bpp -> "Portion size #{bpp.portion_size}"  end) %>
                  <%= for bpp <-o.type.bp_products do %>
                      <.live_component module={EveIndustrexWeb.Common.MiniMarket} tax_rate={@tax_rate} id={Integer.to_string(i)<>"_#{o.type.type_id}_MiniMarket_Product"} item={%{:category_id => o.type.group.category_id,:name => bpp.name, :type_id => bpp.type_id}} selected_order={o.product_order.order} offer_id={o.offer_id} selected_trade_hub={@form[:selected_trade_hub].value} category={:product}/>
                  <% end %>
                <% else %>
                  <.live_component module={EveIndustrexWeb.Common.MiniMarket} tax_rate={@tax_rate} id={Integer.to_string(i)<>"_#{o.type.type_id}_MiniMarket_Product"} item={%{:category_id => o.type.group.category_id,:name => o.type.name, :type_id => o.type.type_id}} selected_order={o.product_order.order} offer_id={o.offer_id} selected_trade_hub={@form[:selected_trade_hub].value} category={:product}/>
                <% end %>

              </div>
            </div>

            <div class="flex flex-col gap-1 w-[8%]">
              <span>isk cost:</span>
              <span><%= Utils.format_with_coma(o.isk_cost) %></span>
              <span>lp cost:</span>
              <span><%= Utils.format_with_coma(o.lp_cost) %></span>
            </div>

            <div  class="flex flex-col w-[30%] ">
              <%= for ri <-o.req_items do %>
                <div class="flex gap-2 justify-between">
                <%= if ri != nil do %>
                  <div class="p-1 flex gap-2 items-center justify-between">
                    <span> <%= ri.type.name %></span>
                    <span> <%= ri.quantity%></span>
                  </div>
                  <.live_component module={EveIndustrexWeb.Common.MiniMarket} offer_id={o.offer_id} category={:ri_materials} tax_rate={@tax_rate} amount={ri.quantity} category={:ri_materials} id={Integer.to_string(i)<>"_#{ri.type_id}_MiniMarket_Materials"} item={%{:category_id => ri.type.group.category_id,:name =>ri.type.name, :type_id => ri.type.type_id}} selected_order={hd(Enum.filter(o.req_items_cost, fn ric -> ric.type_id == ri.type_id end)).order} selected_trade_hub={@form[:selected_trade_hub].value}/>
                <% end %>
                </div>
              <% end %>
            </div>
            <div class="w-[15%]">
              <%= if String.contains?(o.type.name, "Blueprint") do %>
                <span>Production Materials Cost:</span>
                <.live_component module={EveIndustrexWeb.Common.BpMatsCost} tax_rate={@tax_rate} id={Integer.to_string(i)<>"_#{o.type.type_id}_BP_Mats_Cost"} bp_materials={o.bp_mats_cost} production_product={o.type.name} runs={o.quantity} selected_trade_hub={@form[:selected_trade_hub].value} offer_id={o.offer_id}/>
              <% end %>
            </div>

            <div class="flex w-[15%] justify-end">

            <div class="">
            <%= cond do %>
                <% o.product_order.order == :missing_order -> %>
                  Missing Product Price
                <% Enum.any?(o.req_items_cost, fn ric -> ric.order == :missing_order end) -> %>
                  Missing Required Item Price
                <% is_list(o.bp_mats_cost) and Enum.any?(o.bp_mats_cost, fn bmc -> bmc.order == :missing_order end) -> %>
                  Missing Material Price
                <% true -> %>
                  <%= if o.lp_cost == 0 do %>
                    <%= Utils.format_with_coma(o.isk_per_lp) %> Profit
                  <% else %>
                    <%= Utils.format_with_coma(o.isk_per_lp) %> ISK / LP
                  <% end %>
                <% end %>
            </div>
            </div>
          </div>
        <% end %>
        <% @offers.ok? -> %>

          <%= for {o, i} <- Enum.with_index(@offers.result) do %>
          <div class={"flex gap-2 justify-between p-2 ring-2 ring-black/80 rounded-md bg-black/40 w-full max-w-[1800px]"}>
            <div class="flex flex-col justify-between items-start w-[15%]">
                <div class="flex flex-col">
                  <div class="flex gap-2">
                    <%= case o.type.group.category_id do%>
                      <% 9 -> %>
                        <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{o.type.type_id}/bp?size=128"} />
                      <% 91 -> %>
                        <%= nil %>
                      <% _ -> %>
                      <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{o.type.type_id}/icon?size=128"} />
                    <% end %>
                    <span class="font-semibold"><%= o.type.name %></span>
                  </div>
                  <span> <%= if String.contains?(o.type.name, "Blueprint"), do: "Runs: #{o.quantity}", else: "Amount: #{o.quantity}"  %></span>
                </div>
              <div class="flex flex-col justify-center">
            <%= if String.contains?(o.type.name, "Blueprint") do %>
                  <%= Enum.map(o.type.bp_products, fn bpp -> "Portion size #{bpp.portion_size}"  end) %>
                  <%= for bpp <-o.type.bp_products do %>
                      <.live_component module={EveIndustrexWeb.Common.MiniMarket} tax_rate={@tax_rate} id={Integer.to_string(i)<>"_#{o.type.type_id}_MiniMarket_Product"} item={%{:category_id => o.type.group.category_id,:name => bpp.name, :type_id => bpp.type_id}} selected_order={o.product_order.order} offer_id={o.offer_id} selected_trade_hub={@form[:selected_trade_hub].value} category={:product}/>
                  <% end %>
                <% else %>
                  <.live_component module={EveIndustrexWeb.Common.MiniMarket} tax_rate={@tax_rate} id={Integer.to_string(i)<>"_#{o.type.type_id}_MiniMarket_Product"} item={%{:category_id => o.type.group.category_id,:name => o.type.name, :type_id => o.type.type_id}} selected_order={o.product_order.order} offer_id={o.offer_id} selected_trade_hub={@form[:selected_trade_hub].value} category={:product}/>
                <% end %>

              </div>
            </div>

            <div class="flex flex-col gap-1 w-[8%]">
              <span>isk cost:</span>
              <span><%= Utils.format_with_coma(o.isk_cost) %></span>
              <span>lp cost:</span>
              <span><%= Utils.format_with_coma(o.lp_cost) %></span>
            </div>

            <div  class="flex flex-col w-[30%] ">
              <%= for ri <-o.req_items do %>
                <div class="flex gap-2 justify-between">
                <%= if ri != nil do %>
                  <div class="p-1 flex gap-2 items-center justify-between">
                    <span> <%= ri.type.name %></span>
                    <span> <%= ri.quantity%></span>
                  </div>
                  <.live_component module={EveIndustrexWeb.Common.MiniMarket} offer_id={o.offer_id} category={:ri_materials} tax_rate={@tax_rate} amount={ri.quantity} category={:ri_materials} id={Integer.to_string(i)<>"_#{ri.type_id}_MiniMarket_Materials"} item={%{:category_id => ri.type.group.category_id,:name =>ri.type.name, :type_id => ri.type.type_id}} selected_order={hd(Enum.filter(o.req_items_cost, fn ric -> ric.type_id == ri.type_id end)).order} selected_trade_hub={@form[:selected_trade_hub].value}/>
                <% end %>
                </div>
              <% end %>
            </div>
            <div class="w-[15%]">
              <%= if String.contains?(o.type.name, "Blueprint") do %>
                <span>Production Materials Cost:</span>
                <.live_component module={EveIndustrexWeb.Common.BpMatsCost} tax_rate={@tax_rate} id={Integer.to_string(i)<>"_#{o.type.type_id}_BP_Mats_Cost"} bp_materials={o.bp_mats_cost} production_product={o.type.name} runs={o.quantity} selected_trade_hub={@form[:selected_trade_hub].value} offer_id={o.offer_id}/>
              <% end %>
            </div>

            <div class="flex w-[15%] justify-end">

            <div class="">
            <%= cond do %>
                <% o.product_order.order == :missing_order -> %>
                  Missing Product Price
                <% Enum.any?(o.req_items_cost, fn ric -> ric.order == :missing_order end) -> %>
                  Missing Required Item Price
                <% is_list(o.bp_mats_cost) and Enum.any?(o.bp_mats_cost, fn bmc -> bmc.order == :missing_order end) -> %>
                  Missing Material Price
                <% true -> %>
                  <%!-- <%= if o.lp_cost == 0 do %>
                    <%= Utils.format_with_coma(calc_lp(o.lp_cost, {o.product_order.order.price, o.quantity}, o.isk_cost, @tax_rate , o.req_items_cost,
                    {get_bp_mats_cost(o.bp_mats_cost), o.quantity})) %> Profit
                    <% else %>
                    <%= Utils.format_with_coma(calc_lp(o.lp_cost, {o.product_order.order.price, o.quantity}, o.isk_cost, @tax_rate , o.req_items_cost,
                    {get_bp_mats_cost(o.bp_mats_cost), o.quantity})) %> ISK / LP
                  <% end %> --%>
                  <%= if o.lp_cost == 0 do %>
                    <%= Utils.format_with_coma(o.isk_per_lp) %> Profit
                  <% else %>
                    <%= Utils.format_with_coma(o.isk_per_lp) %> ISK / LP
                  <% end %>
                <% end %>
            </div>
            </div>
          </div>
        <% end %>

        <% end %>
        </div>

    """
  end



  def handle_async(:get_orders, {:ok, result}, socket) do
    %{:offers => offers, :tax_rate => tax_rate} = socket.assigns
    offers_with_prices = Enum.map(offers.result, fn o -> insert_prices(o, result, tax_rate) end)

    {:noreply, socket |> assign(:orders, AsyncResult.ok(result)) |> assign(:offers, AsyncResult.ok(offers_with_prices))}
  end
  def handle_async(:get_lp_offers, {:ok, result}, socket) do
    %{:form => form, :tax_rate => tax_rate} = socket.assigns
    trade_hub_id = form[:selected_trade_hub].value

    bp_type_ids = Enum.filter(result, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.bp_products, fn bpp -> bpp.type_id end) end)
    mats_type_ids = Enum.filter(result, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.products, fn p -> p.material_type_id end) end)
    type_ids = [[[Enum.map(result, fn s ->  Enum.map(s.req_items, fn ri -> ri.type_id end)end) | Enum.map(result, &(&1.type.type_id))]|
    bp_type_ids]| mats_type_ids] |> List.flatten() |> Enum.uniq()

    orders = Task.Supervisor.async(EveIndustrex.TaskSupervisor, fn -> Market.dev_get_market_orders_by_type_and_station(type_ids, trade_hub_id) end) |> Task.await()
    offers_with_prices = Enum.map(result, fn r -> insert_prices(r, orders, tax_rate) end)

    {:noreply, socket |> assign(:offers, AsyncResult.ok(offers_with_prices)) |> assign(:orders, %{:result => orders, :loading => false})}
  end

  def handle_event("toggle_form", _unsigned_params, socket) do
    %{:show_form => boolean} = socket.assigns
    {:noreply, socket |> assign(:show_form, !boolean)}
  end
  def handle_event("validate_form",%{"_target" => ["filter items"], "filter items" => string} = _params, socket) do
    %{:offers => offers, :form => form} = socket.assigns

    filtered_offers = filter_offers(offers.result, string)


    params = %{filter: string, selected_trade_hub: form[:selected_trade_hub].value, selected_corp: form[:selected_corp].value}
    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Map.put(:action, :validate)
    {:noreply, socket |> assign(:filtered_offers, filtered_offers) |> assign(:form, to_form(changeset, as: :lp_shop_form))}
  end
  def handle_event("validate_form",%{"_target" => ["corp selection"], "corp selection" => ""} = _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate_form",%{"_target" => ["corp selection"], "corp selection" => corp_id} = _params, socket) do
    %{:form => form} = socket.assigns
    params = %{selected_corp: String.to_integer(corp_id), selected_trade_hub: form[:selected_trade_hub].value, filter: ""}
    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:selected_corp)
    |> Map.put(:action, :validate)
    number_of_offers = Corporation.get_corp_lp_offers_count(params.selected_corp)

    {:noreply, socket |> assign(:filtered_offers, nil) |> assign(:offers, AsyncResult.loading()) |> start_async(:get_lp_offers, fn -> Corporation.get_corp_lp_offers(params.selected_corp) end) |> assign(:form, to_form(changeset, as: :lp_shop_form)) |> assign(:number_of_offers, number_of_offers)}

  end
  def handle_event("validate_form", %{"_target" => ["trade hub select"],"trade hub select" => station_id} = _params, socket) do
    %{:form => form, :offers => offers} = socket.assigns
    params = %{selected_corp: form[:selected_corp].value, selected_trade_hub: station_id, filter: ""}
    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:selected_trade_hub)
    |> Map.put(:action, :validate)

    if params.selected_trade_hub != nil && offers != nil && Map.has_key?(offers, :result) do

      {:noreply, socket |> assign(:filtered_offers, nil) |> assign(:orders, AsyncResult.loading()) |> start_async(:get_orders, fn -> get_new_orders(offers.result, params.selected_trade_hub) end)  |> assign(:form, to_form(changeset, as: :lp_shop_form)) }
    else
      {:noreply, socket |> assign(:filtered_offers, nil) |> assign(:form, to_form(changeset, as: :lp_shop_form))}
    end
  end
  def handle_event("validate_form", %{"_target" => ["sort by"], "sort by" => sorter}, socket) do
    %{:offers => offers, :filtered_offers => filtered_offers} = socket.assigns
    {new_offers, new_filtered_offers} =
      case sorter do
        "name - asc" ->
            sorted_offers = Enum.sort(offers.result, &(&1.type.name < &2.type.name))

            sorted_filtered_offers =  if !is_nil(filtered_offers) and length(filtered_offers) > 0, do: Enum.sort(filtered_offers, &(&1.type.name < &2.type.name)), else: filtered_offers
          {sorted_offers, sorted_filtered_offers}
        "name - desc" ->
            sorted_offers = Enum.sort(offers.result, &(&1.type.name > &2.type.name))
             sorted_filtered_offers =  if !is_nil(filtered_offers) and length(filtered_offers) > 0, do: Enum.sort(filtered_offers, &(&1.type.name > &2.type.name)), else: filtered_offers
          {sorted_offers, sorted_filtered_offers}
        "isk/lp - asc" ->
            sorted_offers = Enum.sort(offers.result, &(&1.isk_per_lp < &2.isk_per_lp))
            sorted_filtered_offers =   if !is_nil(filtered_offers) and length(filtered_offers) > 0, do: Enum.sort(filtered_offers, &(&1.isk_per_lp < &2.isk_per_lp)), else: filtered_offers
          {sorted_offers, sorted_filtered_offers}
        "isk/lp - desc" ->
            sorted_offers = Enum.sort(offers.result, &(&1.isk_per_lp > &2.isk_per_lp))
             sorted_filtered_offers =  if !is_nil(filtered_offers) and length(filtered_offers) > 0, do: Enum.sort(filtered_offers, &(&1.isk_per_lp > &2.isk_per_lp)), else: filtered_offers
          {sorted_offers, sorted_filtered_offers}
      end
    {:noreply, socket |> assign(:offers, Map.replace(offers, :result, new_offers)) |> assign(:filtered_offers, new_filtered_offers)}
  end

  def handle_info({:new_tax_rate, tax_rate}, socket) do
 %{:offers => offers, :filtered_offers => filtered_offers} = socket.assigns
    offers_with_prices = Enum.map(offers.result, fn o -> adjust_isk_per_lp(o, tax_rate) end)
    if !is_nil(filtered_offers) and length(filtered_offers) > 0 do
      filtered =  Enum.map(filtered_offers, fn f -> adjust_isk_per_lp(f, tax_rate) end)
      {:noreply, socket |> assign(:tax_rate, tax_rate) |> assign(:offers, AsyncResult.ok(offers_with_prices)) |> assign(:filtered_offers, filtered)}
    else
      {:noreply, socket |> assign(:tax_rate, tax_rate) |> assign(:offers, AsyncResult.ok(offers_with_prices))}
    end
  end

  def handle_info({:update_order, category, offer_id, order}, socket) do
    %{:offers => offers, :filtered_offers => filtered_offers, :tax_rate => tax_rate} = socket.assigns
    new_filtered_offers =
      if !is_nil(filtered_offers) and length(filtered_offers) > 0  do
        case category do
          :product ->
            Enum.map(filtered_offers, fn o -> if o.offer_id == offer_id, do: Map.replace(o, :product_order, Map.replace(o.product_order, :order, order)), else: o end)
          :ri_materials ->
            req_materials_cost = hd(Enum.filter(filtered_offers, fn o -> o.offer_id == offer_id end)).req_items_cost |> Enum.map(fn ri -> if ri.type_id == order.type_id, do: Map.replace(ri, :order, order), else: ri end)
            Enum.map(filtered_offers, fn o -> if o.offer_id == offer_id, do: Map.replace(o, :req_items_cost, req_materials_cost) , else: o end)
          :bp_materials ->
            bp_materials = hd(Enum.filter(filtered_offers, fn o ->  o.offer_id == offer_id end)).bp_mats_cost |> Enum.map(fn bmc -> if bmc.type_id == order.type_id, do: Map.replace(bmc, :order, order), else: bmc end)
            Enum.map(filtered_offers, fn o -> if o.offer_id == offer_id, do: Map.replace(o, :bp_mats_cost, bp_materials), else: o end )
          end
          |> Enum.map(fn o -> adjust_isk_per_lp(o, tax_rate) end)
      else
         nil
      end

    new_offers =
    case category do
      :product ->
        Enum.map(offers.result, fn o -> if o.offer_id == offer_id, do: Map.replace(o, :product_order, Map.replace(o.product_order, :order, order)), else: o end)
      :ri_materials ->
        req_materials_cost = hd(Enum.filter(offers.result, fn o -> o.offer_id == offer_id end)).req_items_cost |> Enum.map(fn ri -> if ri.type_id == order.type_id, do: Map.replace(ri, :order, order), else: ri end)
        Enum.map(offers.result, fn o -> if o.offer_id == offer_id, do: Map.replace(o, :req_items_cost, req_materials_cost) , else: o end)
      :bp_materials ->
        bp_materials = hd(Enum.filter(offers.result, fn o ->  o.offer_id == offer_id end)).bp_mats_cost |> Enum.map(fn bmc -> if bmc.type_id == order.type_id, do: Map.replace(bmc, :order, order), else: bmc end)
        Enum.map(offers.result, fn o -> if o.offer_id == offer_id, do: Map.replace(o, :bp_mats_cost, bp_materials), else: o end )
    end
    |> Enum.map(fn o -> adjust_isk_per_lp(o, tax_rate) end)


    {:noreply, socket |> assign(:filtered_offers, new_filtered_offers) |> assign(:offers, Map.replace(offers, :result, new_offers))}
  end
  defp get_new_orders(offers, trade_hub_id) do
    bp_type_ids = Enum.filter(offers, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.bp_products, fn bpp -> bpp.type_id end) end)
    mats_type_ids = Enum.filter(offers, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.products, fn p -> p.material_type_id end) end)
    type_ids = [[[Enum.map(offers, fn s ->  Enum.map(s.req_items, fn ri -> ri.type_id end)end) | Enum.map(offers, &(&1.type.type_id))]|
    bp_type_ids]| mats_type_ids] |> List.flatten() |> Enum.uniq()
    Market.dev_get_market_orders_by_type_and_station(type_ids, trade_hub_id)
  end
  defp filter_offers(offers, string) do
     cond  do
      string == "" ->
        nil

      String.contains?(string, ">") && String.length(string) > 1 ->
        amount =
          String.split(String.trim(string), ">")
          |> Enum.map(fn x -> String.trim(x) end)
          |> Enum.at(1)
        amount =
          Regex.run(~r/[0-9]+/, amount)
        if !is_nil(amount) do
          Enum.filter(offers, fn o ->if is_number(o.isk_per_lp), do: o.isk_per_lp > String.to_integer(hd(amount)) end) |> Enum.sort(&(&1.isk_per_lp > &2.isk_per_lp))
        else
          nil
        end

      String.match?(string, ~r/\[[0-9]+..[0-9]+\]/) ->
        range =
          String.splitter(string, ["[", ".", " ", "]"]) |> Enum.to_list |> Enum.filter(fn s -> s !="" end) |> Enum.map(fn s -> String.to_integer(s) end)
          Enum.filter(offers, fn o -> if is_number(o.isk_per_lp), do: hd(range) <= o.isk_per_lp and o.isk_per_lp <= Enum.at(range, 1) end) |> Enum.sort(&(&1.isk_per_lp > &2.isk_per_lp))

      true ->

        Enum.filter(offers, fn o -> String.contains?(String.downcase(o.type.name) , String.downcase(string)) end)
    end
  end
  defp insert_prices(offer, orders, tax_rate) do
    req_items = if length(offer.req_items) > 0, do: Enum.map(offer.req_items, fn ri -> %{:name => ri.type.name,:type_id => ri.type_id, :quantity => ri.quantity} end), else: offer.req_items
    req_items_cost = Enum.map(req_items, fn ri -> Map.put(ri, :order, get_order(Enum.filter(orders, fn o -> o.type_id == ri.type_id end))) end)
    product = if String.contains?(offer.type.name, "Blueprint"), do: %{:name => get_bp_product_name(offer.type.bp_products),:type_id => get_bp_product_type_id(offer.type.bp_products)}, else: %{:type_id => offer.type.type_id, :name => offer.type.name}
    product_order =  Map.put(product, :order, get_order(Enum.filter(orders, fn o -> o.type_id == product.type_id end)))
    bp_mats = if String.contains?(offer.type.name, "Blueprint"), do: Enum.map(offer.type.products, fn bpp -> %{:category_id => bpp.material_type.group.category.category_id ,:name => bpp.material_type.name,:type_id => bpp.material_type_id, :amount => bpp.amount} end), else: 0
    bp_mats_cost = if is_list(bp_mats), do: Enum.map(bp_mats, fn bmc -> Map.put(bmc, :order, get_order(Enum.filter(orders, fn o -> o.type_id == bmc.type_id end))) end), else: bp_mats
    isk_per_lp =
      cond do
        product_order.order == :missing_order ->
          :missing_product_price
        Enum.any?(req_items_cost, fn ric -> ric.order == :missing_order end) ->
          :missing_required_item_price
        is_list(bp_mats_cost) and Enum.any?(bp_mats_cost, fn bmc -> bmc.order == :missing_order end) ->
          :missing_material_price
        true ->

          quantity = if String.contains?(offer.type.name, "Blueprint"), do: offer.quantity * hd(offer.type.bp_products).portion_size, else: offer.quantity

            calc_lp(offer.lp_cost, {product_order.order.price, quantity}, offer.isk_cost, tax_rate , req_items_cost,
            {get_bp_mats_cost(bp_mats_cost), offer.quantity})

      end
    Map.put(offer,:req_items_cost, req_items_cost) |> Map.put(:product_order, product_order) |> Map.put(:bp_mats_cost, bp_mats_cost) |> Map.put(:isk_per_lp, isk_per_lp)
  end

  defp adjust_isk_per_lp(offer, tax_rate) do
    isk_per_lp =
      cond do
        offer.product_order.order == :missing_order ->
          :missing_product_price
        Enum.any?(offer.req_items_cost, fn ric -> ric.order == :missing_order end) ->
          :missing_required_item_price
        is_list(offer.bp_mats_cost) and Enum.any?(offer.bp_mats_cost, fn bmc -> bmc.order == :missing_order end) ->
          :missing_material_price
        true ->
          quantity = if String.contains?(offer.type.name, "Blueprint"), do: offer.quantity * hd(offer.type.bp_products).portion_size, else: offer.quantity
          calc_lp(offer.lp_cost, {offer.product_order.order.price, quantity}, offer.isk_cost, tax_rate , offer.req_items_cost,
        {get_bp_mats_cost(offer.bp_mats_cost), offer.quantity})
        end
    Map.replace(offer, :isk_per_lp, isk_per_lp)
  end
  defp get_bp_product_name([]), do: nil
  defp get_bp_product_name(list_of_products) when is_list(list_of_products), do: hd(list_of_products).name
  defp get_bp_product_type_id([]), do: nil
  defp get_bp_product_type_id(list_of_products) when is_list(list_of_products), do: hd(list_of_products).type_id
  defp get_order(order) when is_list(order) and length(order) == 0, do: :missing_order
  defp get_order(order) when is_list(order) and length(order) > 0, do: hd(order)
  defp calc_lp(_lp_cost, {nil, _product_amount}, _isk_cost, _tax_rate, _req_items, {_total_bp_materials_cost, _amount}) do
      :nil
  end
  defp calc_lp(0, {product_price, product_amount}, isk_cost, tax_rate, req_items, {total_bp_materials_cost, amount}) do

    isk_per_lp =
    (((product_price * ((100 - tax_rate) / 100)) * product_amount ) - (isk_cost + List.foldl(req_items, 0, fn ri, acc -> ri.order.price * ri.quantity + acc end) + (total_bp_materials_cost * amount)))
    isk_per_lp
  end
  defp calc_lp(lp_cost, {product_price, product_amount}, isk_cost, tax_rate, req_items, {total_bp_materials_cost, amount}) do

    isk_per_lp = (((product_price * ((100 - tax_rate) / 100)) * product_amount ) - (isk_cost + List.foldl(req_items, 0, fn ri, acc -> ri.order.price * ri.quantity + acc end) + (total_bp_materials_cost * amount))) / lp_cost
    isk_per_lp
  end
  defp get_bp_mats_cost(bp_mats_cost) do
    if bp_mats_cost == 0, do: bp_mats_cost, else: List.foldl(bp_mats_cost, 0, fn x, acc -> if x == 0, do: 0, else: x.order.price * x.amount + acc end)
  end
end
