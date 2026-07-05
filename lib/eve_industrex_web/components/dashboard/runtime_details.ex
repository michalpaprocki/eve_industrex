defmodule EveIndustrexWeb.Dashboard.RuntimeDetails do
  use EveIndustrexWeb, :live_component

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:show_details, false)}
  end
  def render(assigns) do
    ~H"""
      <div class="flex flex-col gap-2 p-2">
        <.button class="w-[20ch] self-center" phx-click={"toggle_show"} phx-target={@myself}>
          <%= if @show_details, do: "hide details", else: "show details" %>
        </.button>
        <%= if @show_details do %>
          <span class="capitalize p-1 font-semibold">generation: <%= @details.generation %></span>
          <span class="capitalize p-1 font-semibold">target id: <%= @details.target_id %></span>
          <span class="capitalize p-1 font-semibold">started at: <%= DateTime.to_date(@details.started_at) %>  <%= DateTime.to_time(@details.started_at) %></span>
          <span class="capitalize p-1 font-semibold">page: <%= @details.page %></span>
          <span class="capitalize p-1 font-semibold">pages total: <%= @details.pages_total %></span>
        <% else %>

        <% end %>
      </div>
    """
  end

  def handle_event("toggle_show", _unsigned_params, socket) do

    {:noreply, socket |> assign(:show_details, !socket.assigns.show_details)}
  end
end
