defmodule EveIndustrexWeb.Alchemy.MaterialCost do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils

  def update_component(cid, %{:selected_price => selected_price}) do
    send_update(__MODULE__, id: cid, update: %{:selected_price => selected_price})
  end
  def update(%{:update => %{:selected_price => selected_price}} = _assigns, socket) do
    EveIndustrexWeb.Alchemy.Total.update_component(socket.assigns.parent_id<>"_total", %{:material_id => socket.assigns.material_id, :price => selected_price, :amount => socket.assigns.amount })
    {:ok, socket |> assign(:selected_price, selected_price)}
  end
  def update(assigns, socket) do
    material = String.split(assigns.id, "_")
    |> extract_material_id()
    parent_id = String.split(assigns.id, "_")
    |> extract_parent_id()

    {:ok, socket |> assign(assigns) |> assign(:parent_id, parent_id) |> assign(:material_id, material)}

  end

  def render(assigns) do
    ~H"""
      <div class="p-1">
      <%= if Map.has_key?(assigns, :selected_price) and @selected_price != nil do %>
        <span> <%= Utils.format_with_coma(@amount * @selected_price) %>&nbsp;ISK</span>
        <% else %>
        <span class="animate-pulse font-semibold text-lg"> N/A</span>
      <% end %>
      </div>
    """
  end
  defp extract_material_id(string_splitted) do
    if length(string_splitted) > 6 do
      Enum.drop(string_splitted, 4)
      |> hd()
      |> String.to_integer()
    else
      Enum.drop(string_splitted, 3)
      |> hd()
      |> String.to_integer()
    end
  end
  defp extract_parent_id(string_splitted) do
    if length(string_splitted) > 6 do
      Enum.drop(string_splitted, -3)
      |> Enum.join("_")
    else
      Enum.drop(string_splitted, -3)
      |> Enum.join("_")
    end
  end
end
