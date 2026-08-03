defmodule EveIndustrexWeb.Footer do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.ReleaseInfo
  @moduledoc false
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
    <footer class="w-full flex justify-center h-64 bg-black self-end">
      <div class="flex flex-col justify-center gap-5 w-[75%] font-headers py-10">
        <span class="self-center text-lg">
          EveIndusr<span class="trailing-text">EX</span> {ReleaseInfo.get().version}
        </span>
        <nav class="flex flex-col">
          <.link navigate={~p"/operations"} class="p-1 hover:text-ei-hover">Operations</.link>
          <.link navigate={~p"/market"} class="p-1 hover:text-ei-hover">Market</.link>
          <.link navigate={~p"/industry"} class="p-1 hover:text-ei-hover">Industry</.link>
        </nav>
      </div>
    </footer>
    """
  end
end
