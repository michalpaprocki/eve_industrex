defmodule EveIndustrexWeb.ToolsLive do
  use EveIndustrexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section>
      <h1>
        Industrex Tools
      </h1>
      <div class="flex gap-2 flex-col p-4">
        <.link navigate={~p"/tools/alchemy"}>
          Alchemy
        </.link>
        <.link navigate={~p"/tools/appraise"}>
          Appraisal
        </.link>
        <.link navigate={~p"/tools/lp_shop"}>
          Loyalty Points Shop
        </.link>
        <.link navigate={~p"/tools/production"}>
          Production
        </.link>
        <.link navigate={~p"/tools/reactions"}>
          Reactions
        </.link>
      </div>
    </section>
    """
  end
end
