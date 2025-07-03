defmodule EveIndustrexWeb.AlchemyLive do
  alias EveIndustrexWeb.Alchemy.Reaction
  alias Phoenix.LiveView.AsyncResult
  alias EveIndustrex.Market
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.{Reactor, Universe}

  @types ["SELL", "BUY"]
  @skill_levels [0,1,2,3,4,5]
  def mount(_params, _session, socket) do
      {formulas, type_ids} = Reactor.get_alchemy_recipes() # maybe keep this in memory instead of db
      trade_hubs = Universe.get_trade_hubs()


    {:ok, socket
    |> assign(:formulas, formulas)
    |> assign(:orders, AsyncResult.loading())
    |> start_async(:get_orders, fn ->  Market.get_market_orders_by_type_and_station(type_ids, hd(trade_hubs).station_id) end)
    |> assign(:options, trade_hubs)
    |> assign(:skill_levels, @skill_levels)
    |> assign(:type_ids, type_ids)
    |> assign(:types, @types)
    |> assign(:selected_type, hd(@types))
    |> assign(:selected_trade_hub, hd(trade_hubs).station_id)
    |> assign(:selected_skill_level, 0)}
  end

  def render(assigns) do
    ~H"""
    <section>
      <h1 class="text-xl font-bold py-10">Alchemy </h1>
      <div class="flex flex-col gap-8">
        <.live_component module={EveIndustrexWeb.Alchemy.Filter} id="alchemy_filter" options={@options} selected_trade_hub={@selected_trade_hub} selected_skill_level={@selected_skill_level} skill_levels={@skill_levels}/>
        <div class="p-2 flex flex-col gap-1">
        <%= cond  do %>
      <% @orders.loading  -> %>
        <span class="text-center text-xl font-semibold">Loading orders...</span>
        <div class={"mx-auto my-8 h-20 w-20 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
      <% @orders.ok?  -> %>
        <%= for f <- @formulas do %>
          <.live_component module={EveIndustrexWeb.Alchemy.Reaction} id={"reaction_module_"<>Integer.to_string(elem(f, 1).blueprintTypeID)} data={f} selected_type={@selected_type} selected_trade_hub={@selected_trade_hub} type_ids={@type_ids} orders={@orders} selected_skill_level={@selected_skill_level}/>
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

  def handle_event("select_skill", %{"value" => level}, socket) do
    {:noreply, socket |> assign(:selected_skill_level, String.to_integer(level))}
  end
  def handle_info({:fetch, %{:hub => hub}}, socket) do
    type_ids = socket.assigns.type_ids
    {:noreply, socket |> start_async(:get_orders, fn ->  Market.get_market_orders_by_type_and_station(type_ids, hub)end)}
  end

  def handle_async(:get_orders, {:ok, result}, socket) do
    %{:orders => orders} = socket.assigns
    for f <- socket.assigns.formulas do
      Reaction.update_component("reaction_module_"<>Integer.to_string(elem(f, 1).blueprintTypeID), %{:orders => AsyncResult.ok(orders, List.flatten(result))})
    end
    {:noreply, socket |> assign(:orders, AsyncResult.ok(orders, result))}
  end
  def handle_async(:get_orders, {:exit, reason}, socket) do
    %{:orders => orders} = socket.assigns
    {:noreply, socket |> assign(:orders, AsyncResult.failed(orders,{:exit, reason}))}
  end

end
