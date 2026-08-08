defmodule EveIndustrexWeb.LpShop.IskOnLpReturn do
  alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component
  @moduledoc false
  def update_component(cid, %{:update => data}) do
    send_update(__MODULE__, id: cid, update: data)
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col text-base">
      <%= cond do %>
        <% Map.has_key?(@offer, :blueprint) and @offer.prices.products[hd(@offer.blueprint.activities.manufacturing.products).type_id] == nil -> %>
          No product price set
        <% !Map.has_key?(@offer, :blueprint) and @offer.prices.products[@offer.type_id] == nil -> %>
          No product price set
        <% Map.has_key?(@offer, :blueprint) and Enum.any?(@offer.blueprint.activities.manufacturing.materials, fn m -> @offer.prices.materials[m.type_id] == nil end) -> %>
          Missing material item price
        <% length(@offer.req_items) > 0 and Enum.any?(@offer.req_items, fn ri -> @offer.prices.req_items[ri.type_id] == nil end) -> %>
          Missing req item price
        <% @offer.lp_cost == 0 -> %>
          {Utils.format_with_coma(@offer.profit) <> " ISK Profit"}
        <% @offer.isk_on_lp != nil and @offer.profit != nil -> %>
          <div class="flex gap-2 items-center">
            <span class={"min-w-5 h-2 rounded-full mr-2 #{apply_profitability_tag(@offer.isk_on_lp)}"}>
            </span>
            <div class="flex flex-col gap-1">
              <span class="font-bold text-nowrap">
                {Utils.format_with_coma(@offer.isk_on_lp) <> " ISK per LP"}
              </span>
              <span class="text-nowrap text-sm">
                {Utils.format_with_coma(@offer.profit) <> " ISK Profit"}
              </span>
            </div>
          </div>
        <% true -> %>
          :noop
      <% end %>
    </div>
    """
  end

  defp apply_profitability_tag(isk_on_lp) do
    cond do
      isk_on_lp < 0 ->
        "bg-ei-critical shadow-sm shadow-ei-critical"

      isk_on_lp < 500 ->
        "bg-ei-warning shadow-sm shadow-ei-warning"

      isk_on_lp > 500 and isk_on_lp < 1000 ->
        "bg-ei-warn shadow-sm shadow-ei-warn"

      isk_on_lp > 2000 ->
        "bg-ei-accent shadow-md shadow-ei-accent"

      isk_on_lp > 1000 ->
        "bg-ei-success shadow-md shadow-ei-success"

      true ->
        "bg-ei-slate-500"
    end
  end
end
