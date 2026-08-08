defmodule EveIndustrexWeb.Header.Header do
  use EveIndustrexWeb, :live_component
  @moduledoc false
  def update(_assigns, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <header
      class="ei-header fixed w-full z-10 px-8 py-[0.2rem] transition-all delay-300 duration-500"
      phx-hook="HeaderScaling"
      id="_header"
    >
      <nav class="mx-auto flex items-center h-[3.4683rem] gap-2">
        <.header_link
          destination={~p"/"}
          inner_text="EveIndustr"
          trailing_text="EX"
          class="text-xl font-bold"
        />
        <.header_link destination={~p"/item"} inner_text="Item Browser" />
        <.header_link destination={~p"/industry"} inner_text="Industry" />
        <.header_link destination={~p"/market"} inner_text="Market" />
      </nav>
    </header>
    """
  end
end
