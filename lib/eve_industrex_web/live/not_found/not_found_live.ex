defmodule EveIndustrexWeb.NotFoundLive do
  use EveIndustrexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center flex-col items-center min-h-[calc(100vh-20rem)]">
      <h1 class="text-3xl my-20">Page Not Found</h1>
      <p class="text-xl my10">404</p>
    </div>
    """
  end
end
