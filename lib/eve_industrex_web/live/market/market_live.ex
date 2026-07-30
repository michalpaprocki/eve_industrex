defmodule EveIndustrexWeb.MarketLive do
  use EveIndustrexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section>
      <h1 class="text-3xl font-bold mt-20">
        Market
      </h1>
      <div class="flex gap-2 flex-col p-4 mt-20">
        <.nav_panel
          route="/market/lp_shop"
          text="Loyalty Points Browser"
          description="Find profitable deals from NPC corporations' Loyalty Point Shops."
        >
          <:animation>
            <div class="w-28 flex flex-col gap-2 items-start blur-xs opacity-20">
              <div class="flex flex-row items-center gap-2">
                <span class="w-4 h-2 rounded-full block bg-ei-accent " />
                <span class="text-nowrap text-xs">1000ISK/LP</span>
              </div>
              <div class="flex flex-row gap-2">
                <span class="w-4 h-2 rounded-full block bg-ei-critical " />
                <span class="text-nowrap text-xs">-1000ISK/LP</span>
              </div>
              <div class="flex flex-row gap-2">
                <span class="w-4 h-2 rounded-full block bg-ei-warn " />
                <span class="text-nowrap text-xs">500/LP</span>
              </div>
            </div>
          </:animation>
        </.nav_panel>
        <.nav_panel
          route="/market/browser"
          text="Market Browser"
          description="Browse market orders across New Eden."
        >
          <:animation>
            <div class="w-24 h-24 flex justify-evenly relative blur-sm opacity-20 items-center">
              <span class="w-6 block bg-ei-text market-column1 rounded-t-md rounded-b-md" />
              <span class="w-6 block bg-ei-text market-column2 rounded-t-md rounded-b-md" />
              <span class="w-6 block bg-ei-text market-column3 rounded-t-md rounded-b-md" />
            </div>
          </:animation>
        </.nav_panel>
        <.nav_panel route="#" text="Req Items Explorer" description="Coming soon.">
          <:animation>
            <div class="w-24 h-24"></div>
          </:animation>
        </.nav_panel>
      </div>
    </section>
    """
  end
end
