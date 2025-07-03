defmodule EveIndustrexWeb.Market.Filter do
  use EveIndustrexWeb, :live_component


  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:sec_status_filter, %{"highsec" => "true", "lowsec"=> "true", "nullsec" => "true"}) |> assign(:search_string, "")}
  end

  def render(assigns) do
   ~H"""

      <div class={"h-[25%] p-1 right-0 truncate"}>
        <div class="flex items-center gap-1">
            <.label class="hidden" for="location_filter">location</.label>
            <input id="location_filter" value={@search_string} class="rounded-md" type="text" placeholder="🔎 Region / Location..." phx-target={@myself} phx-keyup={"filter_by_location"} phx-debounce={1000}/>
        </div>
        <div class="p-1">
            <.input type="checkbox" name="highsec" checked={true} label="Highsec" phx-click={"filter_by_sec_status"} phx-target={@myself} phx-value-sec_status={"highsec"} />
            <.input type="checkbox" name="lowsec" checked={true} label="Lowsec" phx-click={"filter_by_sec_status"} phx-target={@myself} phx-value-sec_status={"lowsec"} />
            <.input type="checkbox" name="nullsec" checked={true} label="Nullsec" phx-click={"filter_by_sec_status"} phx-target={@myself} phx-value-sec_status={"nullsec"}  />
        </div>
      </div>
    """
  end

  def handle_event("filter_by_location", %{"key"=> _key, "value" => value}, socket) do
    send(self(), {:filter, %{:search_string => value, :sec_status_filter => socket.assigns.sec_status_filter}})
    {:noreply, socket |> assign(:search_string, value)}
  end

  def handle_event("filter_by_sec_status", %{"sec_status" => sec_status}, socket) do
    bool = Map.get(socket.assigns.sec_status_filter, sec_status)
    bool_reversed = if bool == "true", do: "false", else: "true"
    filter = Map.replace(socket.assigns.sec_status_filter, sec_status, bool_reversed)
    send(self(), {:filter, %{:sec_status_filter => filter, :search_string => socket.assigns.search_string}})
  {:noreply, socket |> assign(:sec_status_filter, filter)}
  end
end
