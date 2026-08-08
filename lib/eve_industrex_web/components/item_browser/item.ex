defmodule EveIndustrexWeb.ItemBrowser.Item do
  @moduledoc false
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-1 w-fit p-8">
      <image class="h-24 w-24 rounded-md" alt={@type.name<>" image"} src={@image_url} />
      <span class="p-2">Name: {@type.name}</span>
      <span class="p-2">Group: {@type.group}</span>
      <span class="p-2">Category: {@type.category}</span>
      <%= if @type.description do %>
        <span class="p-2">Description: {@type.description}</span>
      <% end %>
      <%= if @average_price.average_price do %>
        <span class="p-2">
          Average Price: {Utils.format_with_coma(@average_price.average_price)} ISK
        </span>
      <% end %>
    </div>
    """
  end
end
