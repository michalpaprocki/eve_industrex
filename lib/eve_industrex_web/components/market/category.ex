defmodule EveIndustrexWeb.Market.Category do
  use EveIndustrexWeb, :live_component

  def update(assigns, socket) do
      cat_indent = "ml-"<>~s"#{assigns.indent}"
    {:ok, socket |> assign(assigns) |> assign(:cat_indent, cat_indent) |> assign(:open, false) |> assign(:open_types, false)}
  end

  def render(assigns) do
    ~H"""
    <div class={"flex flex-col"}>
      <%!-- add collapse all --%>
      <span class={"hover:bg-black hover:text-white hover:cursor-pointer truncate"} phx-click={if is_struct(@data.types) || !is_struct(@data.types) && length(@data.types) == 0, do: "toggle_open", else: "toggle_open_types"} phx-target={@myself} >
      <.icon name="hero-chevron-right-solid" class="h-4 w-4" />
      <%= @data.name %>
      </span>

      <%= if @data.types && !is_struct(@data.types) && @open_types do %>
        <%= for t <- @data.types do %>
        <div class="px-2 ml-3 hover:bg-black hover:text-white hover:cursor-pointer truncate" phx-click={"fetch_market_orders"} phx-value-type_id={t.type_id}>
            <%= t.name %>
        </div>
        <% end %>
      <% end %>

      <%= for c <- @data.children do %>
      <div class={@cat_indent<>" #{if @open, do: "block", else: "hidden"}"}>
        <.live_component id={c.market_group_id} data={c} module={__MODULE__} indent={@indent}/>
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
