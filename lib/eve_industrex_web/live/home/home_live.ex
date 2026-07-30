defmodule EveIndustrexWeb.HomeLive do
  use EveIndustrexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="max-w-5xl py-32">
      <h1 class="font-headers text-6xl mb-14">
        EveIndustr<span class="text-ei-accent">EX</span>
      </h1>

      <p class="mt-6 text-2xl text-ei-text">
        Industrial intelligence for EVE Online.
      </p>

      <p class="mt-8 max-w-2xl text-lg text-ei-text-muted leading-relaxed">
        Explore loyalty point stores, analyze production chains,
        browse market data and discover profitable opportunities
        using live data from ESI.
      </p>

      <div class="mt-10 flex flex-col gap-4">
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
          route="/industry/reactions"
          text="Reaction Browser"
          description="Browse reaction formulas, product and material prices, see what is profitable."
        >
          <:animation>
            <div class="w-24 h-24  relative reactor-spin blur-sm opacity-20">
              <span class="w-4 h-4 rounded-full block bg-ei-text absolute reactor-arm1" />
              <span class="w-4 h-4 rounded-full block bg-ei-text absolute reactor-arm2" />
              <span class="w-4 h-4 rounded-full block bg-ei-text absolute reactor-arm3" />
            </div>
          </:animation>
        </.nav_panel>
      </div>
    </section>
    """
  end
end
