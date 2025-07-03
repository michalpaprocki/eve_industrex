defmodule EveIndustrexWeb.Market.RegionSearch do
  use EveIndustrexWeb, :live_component

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class="gap-2 flex items-center">
        <.label for="select_region" class="text-xl">Region</.label>
        <select id="select_region">
          <%= Enum.map(@regions, fn r -> %>
            <option value={r.name} selected={r.name==@selected_region} phx-click={"select_region"}>
              <%= r.name %>
            </option>
          <%  end) %>
        </select>
      </div>
    """
  end
end
