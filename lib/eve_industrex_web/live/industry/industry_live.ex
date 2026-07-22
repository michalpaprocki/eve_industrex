defmodule EveIndustrexWeb.IndustryLive do
  use EveIndustrexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section>
      <h1 class="text-3xl font-bold mt-20">
        Industry
      </h1>
      <div class="flex gap-2 flex-col p-4 mt-20">
        <.nav_panel  route={"/industry/reactions"} text="Reaction Browser" description={"Browse reaction formulas, product and material prices, see what is profitable."}>
          <:animation>
             <div class="w-24 h-24  relative reactor-spin blur-sm opacity-20">
              <span class={"w-4 h-4 rounded-full block bg-ei-text absolute reactor-arm1"} />
              <span class={"w-4 h-4 rounded-full block bg-ei-text absolute reactor-arm2"}/>
              <span class={"w-4 h-4 rounded-full block bg-ei-text absolute reactor-arm3"} />
            </div>
          </:animation>
        </.nav_panel>

      </div>
    </section>
    """
  end
end
