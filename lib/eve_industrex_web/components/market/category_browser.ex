defmodule EveIndustrexWeb.Market.CategoryBrowser do
  use EveIndustrexWeb, :live_component
  alias Phoenix.LiveView.AsyncResult
  alias EveIndustrex.Types
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:market_groups, AsyncResult.loading()) |> start_async(:get_market_groups, fn -> Types.get_market_groups() end)
}
  end
  def render(assigns) do
    ~H"""
    <div class="h-full p-1 flex flex-col">
    <h3 class="text-lg pl-2 font-semibold text-start truncate">Market Browser</h3>
      <%= cond do %>
      <% @market_groups.loading -> %>
      <div class="text-center text-xl font-bold my-20">
        Loading market groups...
        <div class={"mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
      </div>
      <% @market_groups.failed -> %>
      Can't fetch market groups data, try again later
      <% @market_groups.ok? -> %>
        <div class="flex flex-col">
        <%= for cat <- @market_groups.result do %>
          <.live_component id={cat.market_group_id} module={EveIndustrexWeb.Market.Category} data={cat} indent={2}/>
        <% end %>
        </div>
      <% end %>
    </div>
    """
  end
  def handle_async(:get_market_groups, {:ok, fetched_market_groups}, socket) do
    %{:market_groups => market_groups} = socket.assigns
    {:noreply, socket |> assign(:market_groups, AsyncResult.ok(market_groups, fetched_market_groups))}
  end
  def handle_async(:get_market_groups, {:exit, reason}, socket) do
    %{:market_groups => market_groups} = socket.assigns
    {:noreply, socket |> assign(:market_groups, AsyncResult.failed(market_groups, {:exit, reason}))}
  end
end
