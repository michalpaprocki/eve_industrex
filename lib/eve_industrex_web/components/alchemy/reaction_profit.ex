defmodule EveIndustrexWeb.Alchemy.ReactionProfit do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component
  def update_component(cid, %{:update => data}) do

    send_update(__MODULE__, id: cid, update: data)
  end
  def update(%{:update => %{:material_total => cost}}, socket) do

    material_cost = Enum.reduce(cost, 0, fn {_id, price}, acc -> acc + price end)
    {:ok, socket |> assign(:material_total, material_cost)}
  end

  def update(%{:update => %{:product_total => income}}, socket) do

    material_income =  Enum.reduce(income, 0, fn {_id, price}, acc -> acc + price end)
    {:ok, socket |> assign(:product_total, material_income)}
  end
  def update(assigns, socket) do

    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class="flex justify-end">
      <span class="font-semibold text-lg">
        <%= if Map.has_key?(assigns, :material_total) && Map.has_key?(assigns, :product_total) do %>
          Profit:
          <span><%= Utils.format_with_coma(@product_total - @material_total) %> &nbsp; ISK</span>
        <% else %>
        <%!-- <div class={"p-2 mx-auto h-6 w-6 rounded-full border-solid border-2 border-[black_transparent_black_transparent] animate-spin"}/> --%>
          N/A
        <% end %>
        </span>
      </div>
    """
  end
end
