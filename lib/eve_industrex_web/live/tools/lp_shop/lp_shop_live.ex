defmodule EveIndustrexWeb.Tools.LpShopLive do

alias EveIndustrex.Universe
alias EveIndustrex.Market
alias EveIndustrex.Utils
alias EveIndustrexWeb.Layouts
alias Phoenix.LiveView.AsyncResult
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Corporation
  def mount(_params, _session, socket) do
    corps = Corporation.get_npc_corps_names_and_ids()
    hubs =  Universe.get_trade_hubs()
    {:ok, socket
     |> assign(:corps, corps)
     |> assign(:selected_corp, nil)
     |> assign(:offers, nil)
     |> assign(:hubs, hubs) , layout: {Layouts, :lp_shop}
    }
  end

  def render(assigns) do
    ~H"""
    <section>
      <h1 class="text-xl font-semibold mb-10"><%= if @selected_corp, do: @selected_corp.name %> Loyalty Points Shop</h1>
      <div class="p-4 flex flex-col  gap-2 ">
        <.label class="text" for={"corp_select"}>Corporation</.label>
        <select class="text">
          <%= for c <- @corps do %>
            <option value={c.corp_id} phx-value-name={c.name} phx-click={"select_corp"}>
              <%= c.name %>
            </option>
          <% end %>
        </select>
      </div>
      <div class="flex flex-col gap-2">
      <%= cond do %>
        <%  @offers == nil -> %>
          <% nil %>
        <% @offers.loading -> %>
         <div class="text-center text-xl font-bold my-20">
            Loading ...
            <div class={"mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
          </div>
        <% @offers.ok? -> %>
          <%= for o <- @offers.result do %>
          <div class="flex gap-2 justify-start p-2 ring-2 ring-black/80 rounded-md ">
            <div class="flex flex-col justify-between items-start min-w-[20%]">
              <span><%= o.type.name %></span>
              <span><%= o.type.type_id %></span>
              <span> <%= if String.contains?(o.type.name, "Blueprint"), do: "Runs: #{o.quantity}", else: "Amount: #{o.quantity}"  %></span>
              <%!-- <.live_component module={EveIndustrexWeb.Market.MiniMarket} id={"MiniMarket_#{o.type.}"} /> --%>
            </div>
            <div class="flex flex-col gap-1 min-w-[10%]">
              <span>isk cost: <%= Utils.format_with_coma(o.isk_cost) %></span>
              <span>lp cost: <%= Utils.format_with_coma(o.lp_cost) %></span>
            </div>
            <div  class="flex flex-col min-w-[20%]">
              <%= for ri <-o.req_items do %>
                <div class=" gap-2">
                  <span> <%= ri.type.name %></span>
                  <span> <%= ri.quantity %></span>
                </div>
              <% end %>
            </div>
            <div class="flex flex-col min-w-[15%]">
                mats market source and price
            </div>
            <div class="flex flex-col min-w-[15%]">
                product market source and price
            </div>
            <div class="flex flex-col min-w-[15%]">
                ratio of isk per lp
            </div>
          </div>
          <% end %>
        <% true -> %>

      <% end %>
      </div>
    </section>
    """
  end

  def handle_event("select_corp", %{"value" => corp_id, "name" => name} = _params, socket) do
    {:noreply, socket |> assign(:selected_corp, %{:id=> corp_id, :name=> name}) |>  assign(:offers, AsyncResult.loading()) |> start_async(:get_lp_offers, fn -> Corporation.get_corp_lp_offers(corp_id) end)}
  end

  def handle_async(:get_lp_offers, {:ok, result}, socket) do
    %{:hubs => trade_hubs} = socket.assigns
    sorted = Enum.sort(result, &(&1.type.name < &2.type.name))
    type_ids = [Enum.map(sorted, fn s ->  Enum.map(s.req_items, fn ri -> ri.type_id end)end) | Enum.map(sorted, &(&1.type.type_id))] |> List.flatten() |> Enum.uniq()
    orders = Task.Supervisor.async(EveIndustrex.TaskSupervisor, fn -> Market.get_market_orders_by_type_and_station(type_ids, hd(trade_hubs).station_id) end) |> Task.await()
    {:noreply, socket |> assign(:offers, AsyncResult.ok(sorted))}
  end
end
