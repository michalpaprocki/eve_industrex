defmodule EveIndustrexWeb.Header.Header do
  use EveIndustrexWeb, :live_component

  def update(_assigns, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <header class="bg-black/70 text-white fixed w-full backdrop-blur-sm z-10 px-8 py-[0.2rem] transition-all delay-300 duration-500" phx-hook={"HeaderScaling"} id="_header">
        <nav class="mx-auto flex items-center h-14 gap-2">
          <.header_link destination={~p"/"} inner_text={"Industrex"} />
          <.header_link destination={~p"/market"} inner_text={"Market"} />
          <.header_link destination={~p"/tools"} inner_text={"Tools"}/>
        </nav>
      </header>
    """
  end
end
