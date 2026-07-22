defmodule EveIndustrexWeb.Market.Category do
alias EveIndustrex.Universe.MarketGroup.Store
  use EveIndustrexWeb, :live_component

  def update(assigns, socket) do
      cat_indent = "ml-"<>~s"#{assigns.indent}"
      %{:market_group => market_group} = assigns
    {:ok, socket |> assign(assigns) |> assign(:cat_indent, cat_indent) |> assign(:types, []) |> assign(:open, false) |> assign(:open_types, false) |> assign(:children, Store.get_market_group_children(market_group.market_group_id)) |> assign(:types, Enum.sort(Store.get_market_group_types(market_group.market_group_id)))}
  end

  def render(assigns) do

    ~H"""
    <div class={"flex flex-col font-headers font-semibold text-base"}>
      <%!-- add collapse all --%>
      <span class={"panel p-1 flex gap-1 hover:bg-black hover:text--eihover hover:cursor-pointer truncate"} phx-click={if length(@types) == 0, do: "toggle_open", else: "toggle_open_types"} phx-target={@myself}>
        <.glyph name="chevron-right" class={" #{if @open or @open_types,  do: "rotate-90", else: "rotate-0"} transition"} />
        <%= @market_group.name %>
      </span>

      <%= for c <- @children do %>
        <div class={@cat_indent<>" #{if @open, do: "block", else: "hidden"}"}>

         <.live_component id={c.market_group_id} market_group={c} module={__MODULE__} indent={@indent}/>
        </div>
      <% end %>
      <%= for t <- @types do %>
        <div class={"#{if @open_types, do: "block", else: "hidden"} px-2 ml-3 panel hover:bg-black hover:text-white hover:cursor-pointer truncate"} phx-click={"fetch_market_orders"} phx-value-type_id={t.type_id}>
            <%= t.name %>
        </div>
      <% end %>

      </div>
    """
  end

  def handle_event("toggle_open", %{}, socket) do

    {:noreply, socket |> assign(:open, !socket.assigns.open)}
  end
  def handle_event("toggle_open_types", %{}, socket) do

    {:noreply, socket |> assign(:open_types, !socket.assigns.open_types)}
  end

end
