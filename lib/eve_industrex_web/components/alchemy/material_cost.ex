defmodule EveIndustrexWeb.Alchemy.MaterialCost do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils

  def update_component(cid, data) do

    send_update(__MODULE__, id: cid, update: data)
  end
  def update(%{:update => %{:selected_price => nil}} = _assigns, socket) do
    {:ok, socket |> assign(:selected_price, nil)}
  end
  def update(%{:update => %{:selected_price => selected_price}} = _assigns, socket) do
    price =
      if socket.assigns.category == :product && Map.has_key?(socket.assigns, :tax_rate) do
        selected_price * ((100 - socket.assigns.tax_rate) / 100)
      else
        selected_price
      end
    EveIndustrexWeb.Alchemy.Total.update_component(socket.assigns.parent_id<>"_total", %{:category => socket.assigns.category, :material_id => socket.assigns.material_id, :price =>  price, :amount => socket.assigns.amount })
    {:ok, socket |> assign(:selected_price, selected_price)}
  end
  def update(%{:update => %{:tax_rate => tax_rate}}, socket) do
      if socket.assigns.category == :product && Map.has_key?(socket.assigns, :selected_price) && socket.assigns.selected_price != nil do

        EveIndustrexWeb.Alchemy.Total.update_component(socket.assigns.parent_id<>"_total", %{:category => socket.assigns.category, :material_id => socket.assigns.material_id, :price =>  socket.assigns.selected_price * ((100 - tax_rate) / 100), :amount => socket.assigns.amount })
      end

    {:ok, socket |> assign(:tax_rate, tax_rate)}
  end
  def update(assigns, socket) do
        send(self(), {:get_tax_rate, __MODULE__, assigns.id})
    material = String.split(assigns.id, "_")
    |> extract_material_id()
    parent_id = String.split(assigns.id, "_")
    |> extract_parent_id()

    {:ok, socket |> assign(assigns) |> assign(:parent_id, parent_id) |> assign(:material_id, material)}

  end

  def render(assigns) do
    ~H"""
      <div class="p-1">

        <%= if Map.has_key?(assigns, :selected_price) &&  Map.has_key?(assigns, :tax_rate) && @selected_price != nil do %>
          <span> <%= if @category == :product, do: Utils.format_with_coma(@amount * (@selected_price * (100 - @tax_rate) / 100)), else: Utils.format_with_coma(@amount * @selected_price) %>&nbsp;ISK</span>
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
      Enum.drop(string_splitted, -3)
      |> Enum.join("_")
  end
end
