defmodule EveIndustrexWeb.Market.Search do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Universe.MarketGroup.Query
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:search_result, [])}
  end

  def render(assigns) do
    ~H"""
      <div class="flex flex-col gap-1 items-center h-[50%]">
        <div class="flex items-center gap-1">
          <.label class="hidden" for={"search"}>Search</.label>
          <input id="search" class="rounded-md text-black" type="text" placeholder="🔎 Search for an item..." phx-target={@myself} phx-keyup="search_for_item" phx-debounce="1000"/>
        </div>

        <div class="flex h-full flex-col w-56 p-2 overflow-y-auto">
          <%= for r <- @search_result do %>
          <span title={r.name} phx-click={"select_type"} phx-target={@myself} phx-value-type_id={r.type_id}
           class="md:text-sm whitespace-nowrap w-full md:p-0 py-1 hover:text-white hover:bg-black hover:cursor-pointer overflow-x-clip"> <%= r.name %> </span>
          <% end %>
        </div>

      </div>
    """
  end

  def handle_event("search_for_item", %{"value" => ""}, socket) do

    {:noreply, socket |> assign(:search_result, [])}
  end
  def handle_event("search_for_item", %{"value" => value}, socket) do
      search_result = Query.get_market_types_by_query(value) |> Enum.sort_by(& &1.name, :asc)
    {:noreply, socket |> assign(:search_result, search_result)}
  end

  def handle_event("select_type", %{"type_id" => type_id}, socket) do
    send(self(), {:fetch_market_orders, type_id})
    {:noreply, socket}
  end
end
