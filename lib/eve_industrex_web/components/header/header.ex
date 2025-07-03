defmodule EveIndustrexWeb.Header.Header do
  use EveIndustrexWeb, :live_component

  def update(_assigns, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <header class="bg-black/70 text-white">
        <nav class="mx-auto px-8 flex items-center gap-2 h-header">
          <.header_link destination={~p"/"} inner_text={"Industrex"} />
          <.header_link destination={~p"/market"} inner_text={"Market"} />
          <.header_link destination={~p"/tools"} inner_text={"Tools"}/>
        </nav>
      </header>
    """
  end
end
