defmodule EveIndustrexWeb.Market.CategoryBrowser do
  use EveIndustrexWeb, :live_component

  alias EveIndustrex.Universe.MarketGroup.Store
  @moduledoc false
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:market_groups, Store.get_init_market_groups())}
  end

  def render(assigns) do
    ~H"""
    <div class="h-full p-1 flex flex-col">
      <div class="flex flex-col">
        <%= for mg <- @market_groups do %>
          <.live_component
            id={elem(mg, 0)}
            module={EveIndustrexWeb.Market.Category}
            market_group={%{name: elem(mg, 1), market_group_id: elem(mg, 0)}}
            indent={2}
            click_event="fetch_market_orders"
          />
        <% end %>
      </div>
    </div>
    """
  end
end
