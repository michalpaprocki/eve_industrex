defmodule EveIndustrexWeb.AlchemyLive do
  alias EveIndustrexWeb.Alchemy.Reaction
  alias Phoenix.LiveView.AsyncResult
  alias EveIndustrex.Market
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.{Reactor, Universe}

  @types ["SELL", "BUY"]

  def mount(_params, _session, socket) do
      {formulas, type_ids} = Reactor.get_alchemy_recipes() # maybe keep this in memory instead of db
      trade_hubs = Universe.get_trade_hubs()

      product_module_ids = Enum.map(formulas, fn {_n, formula} -> formula.blueprint_type_id end)
      product_material_ids = Enum.map(formulas, fn {_m, formula} -> Enum.filter(formula.activities, fn act -> act.activity_type == :reaction end ) end) |> List.flatten() |> Enum.map(fn activities -> Enum.map(activities.products, fn product -> Enum.map(product.product.products, fn prod -> prod.material_type_id end)  end) |> List.flatten() end) |> Enum.zip(product_module_ids)

    {:ok, socket
    |> assign(:formulas, formulas)
    |> assign(:orders, AsyncResult.loading())
    |> start_async(:get_orders, fn ->  Market.get_market_orders_by_type_and_station(type_ids, hd(trade_hubs).station_id) end)
    |> assign(:options, trade_hubs)
    |> assign(:type_ids, type_ids)
    |> assign(:types, @types)
    |> assign(:selected_type, hd(@types))
    |> assign(:selected_trade_hub, hd(trade_hubs).station_id)
    |> assign(:tax_rate, 0.0)
    |> assign(:product_module_ids, product_module_ids)
    |> assign(:product_material_ids, product_material_ids)
  }
  end

  def render(assigns) do
    ~H"""
    <section>
      <h1 class="text-xl font-bold py-10">Alchemy </h1>
      <div class="flex flex-col gap-8">
        <.live_component module={EveIndustrexWeb.Alchemy.Filter} category={:alchemy} id="alchemy_filter" options={@options} selected_trade_hub={@selected_trade_hub} />
        <.live_component module={EveIndustrexWeb.Common.TaxRate} id="alchemy_tax" />
        <div class="p-2 flex flex-col gap-1">
        <%= cond  do %>
      <% @orders.loading  -> %>
        <span class="text-center text-xl font-semibold">Loading orders...</span>
        <div class={"mx-auto my-8 h-20 w-20 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
      <% @orders.ok?  -> %>
        <%= for f <- @formulas do %>
          <.live_component module={EveIndustrexWeb.Alchemy.Reaction} category={:alchemy} id={"reaction_module_"<>Integer.to_string(elem(f, 1).blueprint_type_id)} data={f} selected_type={@selected_type} selected_trade_hub={@selected_trade_hub} type_ids={@type_ids} orders={@orders}/>
        <% end %>

      <%  end %>

        </div>
      </div>
    </section>
    """
  end

  def handle_event("select_trade_hub", %{"value"=> station_id}, socket) do
    send(self(), {:fetch, %{:type => socket.assigns.selected_type, :hub => String.to_integer(station_id)}})
    {:noreply, socket |> assign(:orders, AsyncResult.loading()) |> assign(:selected_trade_hub, String.to_integer(station_id))}
  end


  def handle_info({:fetch, %{:hub => hub}}, socket) do
    type_ids = socket.assigns.type_ids
    {:noreply, socket |> start_async(:get_orders, fn ->  Market.get_market_orders_by_type_and_station(type_ids, hub)end)}
  end
  def handle_info({:new_tax_rate, tax_rate}, socket) do
    %{:product_material_ids => product_material_ids} = socket.assigns

    Enum.map(product_material_ids, fn {mats_ids, bp_id} -> Enum.map(mats_ids, fn mat_id ->

      EveIndustrexWeb.Alchemy.MaterialCost.update_component(~s"reaction_module_#{bp_id}_product_#{mat_id}_material_cost", %{:update => %{:tax_rate => tax_rate}})
      EveIndustrexWeb.Common.MiniMarket.update_component(~s"reaction_module_#{bp_id}_product_#{mat_id}", %{:update => %{:tax_rate => tax_rate}})
    end) end)

    {:noreply, socket |> assign(:tax_rate, tax_rate)}
  end
  def handle_info({:skill_level, level}, socket) do
      product_module_ids = socket.assigns.product_module_ids
      Enum.map(product_module_ids, fn id ->

        EveIndustrexWeb.Alchemy.Product.update_component("reaction_module_"<>Integer.to_string(id)<>"_product", %{:update => %{:skill_level => level}})
        EveIndustrexWeb.Alchemy.Product.update_component("reaction_module_"<>Integer.to_string(id)<>"_product", %{:update => %{:skill_level => level}})
      end)

    {:noreply, socket}
  end
  def handle_info({:get_tax_rate, module, cid}, socket) do
      send_update(module, id: cid, update: %{:tax_rate => socket.assigns.tax_rate})
    {:noreply, socket}
  end
  def handle_async(:get_orders, {:ok, result}, socket) do
    %{:orders => orders} = socket.assigns

    for f <- socket.assigns.formulas do
      Reaction.update_component("reaction_module_"<>Integer.to_string(elem(f, 1).blueprint_type_id), %{:orders => AsyncResult.ok(orders, List.flatten(result))})
    end
    {:noreply, socket |> assign(:orders, AsyncResult.ok(orders, result))}
  end
  def handle_async(:get_orders, {:exit, reason}, socket) do
    %{:orders => orders} = socket.assigns
    {:noreply, socket |> assign(:orders, AsyncResult.failed(orders,{:exit, reason}))}
  end


end
