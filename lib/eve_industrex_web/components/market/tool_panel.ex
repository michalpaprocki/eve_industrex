defmodule EveIndustrexWeb.Market.ToolPanel do
  use EveIndustrexWeb, :live_component

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)
    |> assign(:tree, true)
    |> assign(:filters, true)}
  end

  def render(assigns) do
    ~H"""
    <aside class={"relative flex flex-col items-center rounded-md ring-black md:mb-0 mb-2 md:mr-2 mr-0 transition-all #{if !@tree && !@filters, do: "ring-0 h-0", else: "md:ring-2 ring-0 h-[80vh] min-h-[750px]"}"}>
      <div class="absolute top-0 left-0 -translate-y-12 flex gap-1">
          <.button class={"#{if @tree, do: "", else: "bg-zinc-500"}"} phx-click={"toggle_tree"} phx-target={@myself}>
            browser
          </.button>
          <.button class={"#{if @filters, do: "", else: "bg-zinc-500"}"} phx-click={"toggle_filters"} phx-target={@myself}>
            filters
          </.button>
      </div>
      <div class={"flex h-full"}>
        <div class={"#{if @tree, do: "w-64", else: "w-0"} overflow-auto transition-all duration-700"}>
        <.live_component id={"market_category_browser"} module={EveIndustrexWeb.Market.CategoryBrowser} />
        </div>
        <div class={"#{if @filters, do: "w-64", else: "w-0"} flex flex-col overflow-clip transition-all duration-700"}>
        <.live_component id={"item_showcase"} module={EveIndustrexWeb.Market.Showcase} />
        <.live_component id={"market_filter"} module={EveIndustrexWeb.Market.Filter} />
        <.live_component id={"item_search"} module={EveIndustrexWeb.Market.Search} />
        </div>
      </div>
    </aside>
    """
  end

  def handle_event("toggle_tree", %{"value" => _value}, socket) do
    {:noreply, socket |> assign(:tree, !socket.assigns.tree)}
  end
  def handle_event("toggle_filters", %{"value" => _value}, socket) do
    {:noreply, socket |> assign(:filters, !socket.assigns.filters)}
  end
end
