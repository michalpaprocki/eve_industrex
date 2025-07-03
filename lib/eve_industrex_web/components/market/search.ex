defmodule EveIndustrexWeb.Market.Search do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Types
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:search_result, [])}
  end

  def render(assigns) do
    ~H"""
      <div class="flex flex-col gap-1 h-[50%]">
        <div class="flex items-center gap-1">
          <.label class="hidden" for={"search"}>Search</.label>
          <input id="search" class="rounded-md" type="text" placeholder="🔎 Search for an item..." phx-target={@myself} phx-keyup="search_for_item" phx-debounce="1000"/>
        </div>

        <div class="flex h-full flex-col p-2 w-full overflow-y-auto">
          <%= for r <- @search_result do %>
          <span phx-click={"select_type"} phx-target={@myself} phx-value-type_id={r.type_id}
           class="md:text-sm whitespace-nowrap md:p-0 py-1 hover:text-white hover:bg-black hover:cursor-pointer"> <%= r.name %> </span>
          <% end %>
        </div>

      </div>
    """
  end

  def handle_event("search_for_item", %{"value" => value}, socket) do
      search_result = Types.get_types_by_query(value)
    {:noreply, socket |> assign(:search_result, search_result)}
  end

  def handle_event("select_type", %{"type_id" => type_id}, socket) do
    send(self(), {:fetch_market_orders, type_id})
    {:noreply, socket}
  end
end
