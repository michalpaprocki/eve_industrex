defmodule EveIndustrexWeb.Tools.ProductionLive do
  use EveIndustrexWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <section>
        <h1>Production</h1>
      </section>
    """
  end
end
