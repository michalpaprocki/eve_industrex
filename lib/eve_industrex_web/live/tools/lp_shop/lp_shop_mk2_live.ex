defmodule EveIndustrexWeb.Tools.LpShopMk2Live do

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
     |> assign(:initial_tax_rate, 0.0)
     |> assign(:tax_rate, nil)
     |> assign(:form, to_form(changeset, as: :lp_shop_form))
     |> assign(:orders, [])
     |> assign(:hubs, hubs) , layout: {Layouts, :lp_shop}
    }
  end

  def render(assigns) do
    ~H"""
      <div class="text-xl font-semibold mb-10 h-30 flex flex-col gap-5 mt-10">
        <div class="flex gap-3 flex-col items-center top-20 left-0 w-full">
          <h1 class=""><%= if @form[:selected_corp].value != nil, do:  hd(Enum.filter(@corps, fn c -> c.corp_id == @form[:selected_corp].value end)).name %> Loyalty Points Shop</h1>
          <%= if @form[:selected_corp].value != nil do %>
            <img class="w-80 h-80 blur-sm fixed -z-10" src={"https://images.evetech.net/corporations/#{@form[:selected_corp].value}/logo?size=256"} />
          <% end %>
        </div>
      <%= if Map.has_key?(assigns, :number_of_offers) do %>
        <span><%= @number_of_offers %> Offers Found</span>
      <% end %>
      </div>
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
        <div>
        Hint: You can click on a product or material price to adjust it to your liking.
        </div>
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
          <.live_component id={~s"#{i}_#{o.type_id}"} module={EveIndustrexWeb.LpShop.LpShopItem} orders={@orders} offer={o} tax_rate={@initial_tax_rate}/>
        <% end %>
        <% true -> %>

        <% end %>
      </div>
    """
  end

  def handle_async(:get_lp_offers, {:ok, result}, socket) do
    %{:offers => _offers, :form => form} = socket.assigns
    trade_hub_id = form[:selected_trade_hub].value

    sorted = result

    bp_type_ids = Enum.filter(result, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.bp_products, fn bpp -> bpp.type_id end) end)
    mats_type_ids = Enum.filter(result, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.products, fn p -> p.material_type_id end) end)
    type_ids = Enum.map(sorted, fn s ->  Enum.map(s.req_items, fn ri -> ri.type_id end)end) ++ Enum.map(sorted, &(&1.type.type_id)) ++
    bp_type_ids ++ mats_type_ids |> List.flatten() |> Enum.uniq()


    orders = Task.Supervisor.async(EveIndustrex.TaskSupervisor, fn -> Market.dev_get_market_orders_by_type_and_station(type_ids, trade_hub_id) end) |> Task.await()
    {:noreply, socket |> assign(:offers, AsyncResult.ok(sorted)) |> assign(:orders, %{:result => orders, :loading => false})}
  end
    def handle_async(:get_orders, {:ok, result}, socket) do
    {:noreply, socket |> assign(:orders, AsyncResult.ok(result))}
  end
  def handle_event("validate_form",%{"_target" => ["corp selection"], "corp selection" => corp_id,} = _params, socket) do
    %{:form => form, :tax_rate => tax_rate, :initial_tax_rate => initial_tax_rate} = socket.assigns
    params = %{selected_corp: String.to_integer(corp_id), selected_trade_hub: form[:selected_trade_hub].value}
    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:selected_corp)
    |> Map.put(:action, :validate)
    number_of_offers = Corporation.get_corp_lp_offers_count(params.selected_corp)
    new_tax_rate =
      if tax_rate == nil do
        initial_tax_rate
      else
        tax_rate
      end
    {:noreply, socket |> assign(:offers, AsyncResult.loading()) |> start_async(:get_lp_offers, fn -> Corporation.get_corp_lp_offers(params.selected_corp) end) |> assign(:form, to_form(changeset, as: :lp_shop_form)) |> assign(:number_of_offers, number_of_offers) |> assign(:initial_tax_rate, new_tax_rate)}
  end
  def handle_event("validate_form", %{"_target" => ["trade hub select"],"trade hub select" => station_id} = _params, socket) do
    %{:form => form, :offers => offers, :tax_rate => tax_rate, :initial_tax_rate => initial_tax_rate} = socket.assigns
    params = %{selected_corp: form[:selected_corp].value, selected_trade_hub: station_id}
    changeset =
    {form, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    |> Ecto.Changeset.validate_required(:selected_trade_hub)
    |> Map.put(:action, :validate)
    new_tax_rate =
      if tax_rate == nil do
        initial_tax_rate
      else
        tax_rate
      end
    if params.selected_trade_hub != nil && offers != nil && Map.has_key?(offers, :result) do

      {:noreply, socket |> assign(:orders, AsyncResult.loading()) |> start_async(:get_orders, fn -> get_new_orders(offers.result, params.selected_trade_hub) end)  |> assign(:form, to_form(changeset, as: :lp_shop_form)) |> assign(:initial_tax_rate, new_tax_rate)}
    else
      {:noreply, socket |> assign(:form, to_form(changeset, as: :lp_shop_form))}
    end
  end
  def handle_info({:new_tax_rate, tax_rate}, socket) do
      %{:offers => offers} = socket.assigns
      if offers == nil || !Map.has_key?(offers, :result) || !Map.has_key?(offers, :result) && offers.result == nil do
        {:noreply, socket |> assign(:tax_rate, tax_rate)}
      else
        components_ids = Enum.map(Enum.with_index(offers.result), fn {o, i} ->
            ~s"#{i}_#{o.type_id}_Product"
        end)  |> List.flatten()
        Enum.map(components_ids, fn cid ->
          EveIndustrexWeb.LpShop.LpMiniMarket.update_component(cid, %{:update => %{:tax_rate => tax_rate}})
        end)
    end
  {:noreply, socket |> assign(:tax_rate, tax_rate)}
  end

  defp get_new_orders(offers, trade_hub_id) do
    bp_type_ids = Enum.filter(offers, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.bp_products, fn bpp -> bpp.type_id end) end)
    mats_type_ids = Enum.filter(offers, fn r -> String.contains?(String.downcase(r.type.name), "blueprint") end) |> Enum.map(fn offer -> Enum.map(offer.type.products, fn p -> p.material_type_id end) end)
    type_ids = [[[Enum.map(offers, fn s ->  Enum.map(s.req_items, fn ri -> ri.type_id end)end) | Enum.map(offers, &(&1.type.type_id))]|
    bp_type_ids]| mats_type_ids] |> List.flatten() |> Enum.uniq()
    Market.get_market_orders_by_type_and_station(type_ids, trade_hub_id)
  end
end
