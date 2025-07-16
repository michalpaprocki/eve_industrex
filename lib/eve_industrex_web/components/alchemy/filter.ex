defmodule EveIndustrexWeb.Alchemy.Filter do
  use EveIndustrexWeb, :live_component
  @skill_levels [0,1,2,3,4,5]

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)
    |> assign(:skill_levels, @skill_levels) |> assign(:selected_skill_level, 0)}
  end


  def render(assigns) do
    ~H"""
       <div class="flex items-center gap-2">
          <div class="flex flex-col gap-1">
            <.label class="" for={"trade_hub_select"}>Trade Hub</.label>
            <select class="rounded-md" id="trade_hub_select">
              <%= for o <- @options do %>
                <option selected={if @selected_trade_hub == o.station_id, do: true} phx-click="select_trade_hub" value={o.station_id}><%= o.name %></option>
              <% end %>
            </select>
          </div>
          <%= if assigns.category == :alchemy do %>

          <div class="flex flex-col gap-1">
            <.label class="" for={"reprocess_skill"}>Reprocessing Skill</.label>
            <select class="rounded-md" id="reprocess_skill">
              <%= for l <- @skill_levels do %>
                <option selected={if @selected_skill_level == l, do: true} phx-click="select_skill" phx-target={@myself} value={l}><%= l %></option>
              <% end %>
            </select>
          </div>
        <% end %>
        </div>
    """
  end
    def handle_event("select_skill", %{"value" => level}, socket) do
      send(self(), {:skill_level, level})
    {:noreply, socket |> assign(:selected_skill_level, String.to_integer(level))}
  end
end
