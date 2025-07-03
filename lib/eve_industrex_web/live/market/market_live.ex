defmodule EveIndustrexWeb.Market.MarketLive do
alias EveIndustrex.Schemas.Type
alias EveIndustrexWeb.Layouts
alias EveIndustrex.Market
alias Phoenix.LiveView.AsyncResult
alias EveIndustrex.Types

  use EveIndustrexWeb, :live_view

def mount(%{"path" => id} = _params, _session, socket) do
  case Types.get_type(hd(id)) do
    %Type{type_id: type_id} ->
      EveIndustrexWeb.Market.Showcase.update_component("item_showcase", type_id)
      {:ok, socket
      |> assign(:filtered_orders, [])
      |> assign(:market_orders, AsyncResult.loading())
      |> start_async(:get_market_orders, fn -> Market.get_market_orders(type_id) end)
      |> assign(:search_result, []),
       layout: {Layouts,:market}}
    _->
      {:ok, socket
      |> assign(:filtered_orders, [])
      |> assign(:market_orders, AsyncResult.loading())
      |> assign(:search_result, []),
       layout: {Layouts,:market}}
  end


 end
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:filtered_orders, [])
      |> assign(:market_orders, [])
      |> assign(:search_result, []),
       layout: {Layouts,:market}}
  end

  def render(assigns) do
    ~H"""
      <div class="w-full ">
        <%= cond do %>
          <% @market_orders == []-> %>
          <div class="w-full">
            <h4 class="text-lg font-semibold">Sellers</h4>
            <div class="h-[38vh] min-h-[325px] overflow-auto rounded-md">
              <.live_component id={"sell_orders"} module={EveIndustrexWeb.Market.Orders} data={[]} is_buy_list?={false}/>
            </div>
            <h4 class="text-lg font-semibold">Buyers</h4>
            <div class="h-[38vh] min-h-[325px] overflow-auto rounded-md">
              <.live_component id={"buy_orders"} module={EveIndustrexWeb.Market.Orders} data={[]} is_buy_list?={true}/>
            </div>
          </div>
          <% @market_orders.loading -> %>
          <div class="text-center text-xl font-bold my-20">
            Loading orders...
            <div class={"mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
          </div>
          <% @market_orders.failed -> %>
            Can't fetch orders data, try again later
          <% @market_orders.ok? -> %>
          <div class="flex flex-col gap-2 justify-between h-[80vh] ">
            <h4 class="text-lg font-semibold">Sellers</h4>
            <div class="h-[38vh] min-h-[325px] overflow-auto rounded-md">
              <.live_component id={"sell_orders"} module={EveIndustrexWeb.Market.Orders} data={if @filtered_orders !=[], do: @filtered_orders.sell_orders, else: @market_orders.result.sell_orders} is_buy_list?={false}/>
            </div>
            <h4 class="text-lg font-semibold">Buyers</h4>
            <div class="h-[38vh] min-h-[325px] overflow-auto rounded-md">
              <.live_component id={"buy_orders"} module={EveIndustrexWeb.Market.Orders} data={if @filtered_orders !=[], do: @filtered_orders.buy_orders, else: @market_orders.result.buy_orders} is_buy_list?={true}/>
            </div>
          </div>
        <% end %>
      </div>
    """
  end
  def handle_params(_unsigned_params, _uri, socket) do

    {:noreply, socket}
  end
  def handle_async(:get_regions, {:ok, fetched_regions}, socket) do
    %{:regions => regions} = socket.assigns
    sorted_regions = Enum.sort(fetched_regions, &(&1.name < &2.name))
    {:noreply, socket |> assign(:regions, AsyncResult.ok(regions, [%{:name => "All", :type_id => nil}|sorted_regions]))}
  end
  def handle_async(:get_regions, {:exit, reason}, socket) do
    %{:regions => regions} = socket.assigns

    {:noreply, socket |> assign(:regions, AsyncResult.failed(regions, {:exit, reason}))}
  end
  def handle_async(:get_market_orders, {:ok, fetched_market_orders}, socket) do

    %{:market_orders => market_orders} = socket.assigns

      buy_orders = Enum.filter(fetched_market_orders, fn mo -> mo.is_buy_order == true end)
      sell_orders = Enum.filter(fetched_market_orders, fn mo -> mo.is_buy_order == false end)
    {:noreply, socket |> assign(:market_orders, AsyncResult.ok(market_orders, %{:buy_orders => buy_orders, :sell_orders => sell_orders}))}
  end
  def handle_async(:get_market_orders, {:exit, reason}, socket) do
    %{:market_orders => market_orders} = socket.assigns

    {:noreply, socket |> assign(:market_orders, AsyncResult.failed(market_orders, {:exit, reason}))}
  end
  def handle_async(:get_market_groups, {:ok, fetched_market_groups}, socket) do
    %{:market_groups => market_groups} = socket.assigns


    {:noreply, socket |> assign(:market_groups, AsyncResult.ok(market_groups, fetched_market_groups))}
  end
  def handle_async(:get_market_groups, {:exit, reason}, socket) do
    %{:market_groups => market_groups} = socket.assigns
    {:noreply, socket |> assign(:market_groups, AsyncResult.failed(market_groups, {:exit, reason}))}
  end

  def handle_event("fetch_market_orders", %{"type_id" => type_id}, socket) do
    send(self(), {:fetch_market_orders, type_id})
    {:noreply, socket}
  end

  def handle_info({:fetch_market_orders, type_id}, socket) do
    EveIndustrexWeb.Market.Showcase.update_component("item_showcase", type_id)
    {:noreply, socket |> assign(:market_orders, AsyncResult.loading()) |> start_async(:get_market_orders, fn -> Market.get_market_orders(String.to_integer(type_id)) end) |> assign(:search_result, []) |> push_patch(to: "/market/#{type_id}", replace: true)}
  end

  def handle_info({:filter, %{:sec_status_filter => sec_status_filter, :search_string => search_string}}, socket) do
    filtered_orders = filter(socket.assigns.market_orders, sec_status_filter, search_string)
    {:noreply, socket |> assign(:filtered_orders, filtered_orders)}
  end

  defp filter(orders, sec_status_filter, search_string) do
    if String.length(search_string) == 0 do
      filtered_orders = filter_by_sec_status(orders, sec_status_filter)
     filtered_orders
    else
      filtered_by_location = filter_orders_by_location(orders, search_string)
      filtered_orders = filter_by_sec_status(%{:result => filtered_by_location}, sec_status_filter)
      filtered_orders
    end
  end
  defp filter_orders_by_location([], _string), do: []
  defp filter_orders_by_location(%{:result => %{:buy_orders => buy_orders, :sell_orders => sell_orders}} = _orders, string) do
    filtered_buy_orders = Enum.filter(buy_orders, fn b -> String.contains?(String.downcase(b.station.name), String.downcase(string)) || String.contains?(String.downcase(b.station.system.name), String.downcase(string)) || String.contains?(String.downcase(b.station.system.constellation.region.name), String.downcase(string)) end)
    filtered_sell_orders = Enum.filter(sell_orders, fn s -> String.contains?(String.downcase(s.station.name), String.downcase(string)) || String.contains?(String.downcase(s.station.system.name), String.downcase(string)) || String.contains?(String.downcase(s.station.system.constellation.region.name), String.downcase(string)) end)
    %{:buy_orders => filtered_buy_orders, :sell_orders => filtered_sell_orders}
  end

  defp filter_by_sec_status(%{:result => []}, _sec_status), do: []
  defp filter_by_sec_status(%{:result => %{:buy_orders => buy_orders, :sell_orders => sell_orders}}, %{"highsec" => "true", "lowsec" => "true", "nullsec" => "true"}), do: %{:buy_orders => buy_orders, :sell_orders => sell_orders}
  defp filter_by_sec_status(%{:result => %{:buy_orders => _buy_orders, :sell_orders => _sell_orders}}, %{"highsec" => "false", "lowsec" => "false", "nullsec" => "false"}), do: %{:buy_orders => [], :sell_orders => []}
  defp filter_by_sec_status(%{:result => %{:buy_orders => buy_orders, :sell_orders => sell_orders}}, sec_status_filter) do
    filter =
    case sec_status_filter do
      %{"highsec" => "true", "lowsec" => "true", "nullsec" => "false"} -> #high and low
        0.0
      %{"highsec" => "true", "lowsec" => "false", "nullsec" => "false"} -> #high
        0.5
      %{"highsec" => "false", "lowsec" => "false", "nullsec" => "true"} -> # null
        {0.0, -1}
      %{"highsec" => "false", "lowsec" => "true", "nullsec" => "false"} -> #low
        {0.5, 0.0}
      %{"highsec" => "true", "lowsec" => "false", "nullsec" => "true"} -> #high and null
        [0.5, 0.0]
      %{"highsec" => "false", "lowsec" => "true", "nullsec" => "true"} -> #low and null
        {0.4,-1}
    end

    cond do
      is_float(filter) ->
        filtered_buy_orders = Enum.filter(buy_orders, fn b -> b.station.system.security_status > filter end)
        filtered_sell_orders = Enum.filter(sell_orders, fn s -> s.station.system.security_status > filter  end)
        %{:buy_orders => filtered_buy_orders, :sell_orders => filtered_sell_orders}
      is_tuple(filter) ->
        filtered_buy_orders = Enum.filter(buy_orders, fn b -> b.station.system.security_status <= elem(filter, 0) && b.station.system.security_status >= elem(filter, 1) end)
        filtered_sell_orders = Enum.filter(sell_orders, fn s -> s.station.system.security_status <= elem(filter, 0) && s.station.system.security_status >= elem(filter, 1) end)
        %{:buy_orders => filtered_buy_orders, :sell_orders => filtered_sell_orders}
      true ->
        filtered_buy_orders = Enum.filter(buy_orders, fn b -> b.station.system.security_status >= hd(filter) ||  b.station.system.security_status <= hd(tl(filter)) end)
        filtered_sell_orders = Enum.filter(sell_orders, fn s -> s.station.system.security_status >= hd(filter) ||  s.station.system.security_status <= hd(tl(filter))end)
        %{:buy_orders => filtered_buy_orders, :sell_orders => filtered_sell_orders}
      end
  end
end
