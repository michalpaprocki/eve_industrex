defmodule EveIndustrexWeb.Alchemy.Filter do
  use EveIndustrexWeb, :live_component


  def update(assigns, socket) do
    if Map.has_key?(assigns, :selected_skill_level) do

      {:ok, socket |> assign(assigns)}
    else

      {:ok, socket |> assign(assigns) |> assign(:selected_skill_level, nil)}
    end

  end

  def render(%{:selected_skill_level => nil} = assigns) do
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
      </div>
    """
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
          <div class="flex flex-col gap-1">
            <.label class="" for={"reprocess_skill"}>Reprocessing Skill</.label>
            <select class="rounded-md" id="reprocess_skill">
              <%= for l <- @skill_levels do %>
                <option selected={if @selected_skill_level == l, do: true} phx-click="select_skill" value={l}><%= l %></option>
              <% end %>
            </select>
          </div>
        </div>
    """
  end
end
