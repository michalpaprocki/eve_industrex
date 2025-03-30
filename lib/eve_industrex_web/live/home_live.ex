defmodule EveIndustrexWeb.HomeLive do
  use EveIndustrexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <section>
      home
      </section>
    """
  end
end
