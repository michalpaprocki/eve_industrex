defmodule EveIndustrexWeb.NavPanel do
  use Phoenix.Component

  slot :animation, required: true
  attr :text, :string, required: true
  attr :route, :string, required: true
  attr :description, :string, default: ""



  def nav_panel(assigns) do

    ~H"""
      <.link navigate={@route} class={}>
        <div class="panel shard p-4 flex flex-col h-56 gap-4 hover:shadow-md hover:shadow-hover hover:-translate-y-1 transition hover:bg-ei-hover/20">
          <div class="flex justify-between">
            <span class="text-2xl font-bold font-headers"><%= @text %></span>
              <%= render_slot(@animation) %>
          </div>
          <div class="flex-grow text-left text-sm flex items-end">
            <%= @description %>
          </div>
        </div>
      </.link>
    """
  end
end
