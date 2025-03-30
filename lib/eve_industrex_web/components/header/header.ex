defmodule EveIndustrexWeb.Header.Header do
  use EveIndustrexWeb, :live_component

  def update(_assigns, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <header class="p-8">
        <nav class="flex gap-2 ">
          <.header_link destination={~p"/"} inner_text={"Industrex"} />
          <.header_link destination={~p"/alchemy"} inner_text={"Alchemy"}/>
        </nav>
      </header>
    """
  end
end
