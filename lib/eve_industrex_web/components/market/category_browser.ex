defmodule EveIndustrexWeb.Market.CategoryBrowser do
  use EveIndustrexWeb, :live_component
  alias Phoenix.LiveView.AsyncResult
  alias EveIndustrex.Universe.MarketGroup.Store
  def update(assigns, socket) do

    {:ok, socket |> assign(assigns) |> assign(:market_groups, Store.get_init_market_groups())
}
  end
  def render(assigns) do
    ~H"""
    <div class="h-full p-1 flex flex-col">

        <div class="flex flex-col">
        <%= for mg <- @market_groups do %>
          <.live_component id={elem(mg, 0)} module={EveIndustrexWeb.Market.Category} market_group={%{name: elem(mg, 1), market_group_id: elem(mg,0)}} indent={2}/>
        <% end %>
        </div>
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
