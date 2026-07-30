defmodule EveIndustrexWeb.Reaction do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  alias EveIndustrex.Market

  def update(assigns, socket) do
    eiv =
      Enum.reduce(assigns.reaction.bp.activities.reaction.materials, 0, fn x, acc ->
        x.quantity * assigns.reaction.adjusted_prices[x.type_id].adjusted_price + acc
      end)

    {:ok, socket |> assign(assigns) |> assign(:eiv, eiv)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-2 text-sm rounded-md flex flex-col bg-surface border-1 border-surface-border shard">
      <div class="flex gap-1 items-center justify-between">
        <div class="flex gap-1">
          <img
            class="h-10 w-10 block"
            src={"https://images.evetech.net/types/#{@reaction.type.type_id}/bp?size=128"}
          />
          <div class="flex flex-col">
            <span class="text-ei-text">{@reaction.type.name}</span>
            <span class="text-ei-text-muted text-xs">{@reaction.type.group}</span>
          </div>
        </div>
        <%= if not is_nil(@reaction.profit) do %>
          <span class={"min-w-5 h-2 rounded-full mr-2 #{apply_profitability_tag(@reaction.profit - ((@eiv * @structure_tax) +(@eiv * @ssc_tax) + (@eiv * @system_cost_index |> Market.Service.apply_fw_discount(@fw_upgrade))))}"}>
          </span>
        <% end %>
      </div>
      <div class="p-1 flex justify-between ">
        <span class="text-ei-text">Profit: </span>

        <%= if not is_nil(@reaction.profit) do %>
          <span class="text-ei-text">{Utils.format_with_coma(@reaction.profit)} ISK</span>
        <% else %>
          <span class="text-ei-text">N/A </span>
        <% end %>
      </div>
      <div class="p-1 flex justify-between">
        <span class="text-ei-text">Profit after taxes: </span>
        <%= if not is_nil(@reaction.profit) do %>
          <span class="text-ei-text">
            {Utils.format_with_coma(
              @reaction.profit -
                (@eiv * @structure_tax + @eiv * @ssc_tax +
                   ((@eiv * @system_cost_index) |> Market.Service.apply_fw_discount(@fw_upgrade)))
            )} ISK
          </span>
        <% else %>
          <span class="text-ei-text">N/A </span>
        <% end %>
      </div>
      <div class="p-1 flex flex-col border-t-2 border-dotted border-ei-text-muted mt-4 py-2">
        <span class="text-ei-text-muted">Products: </span>

        <%= for p <- @reaction.bp.activities.reaction.products do %>
          <div class="flex p-1 gap-1 items-center">
            <div class="flex text-ei-text-muted justify-between gap-1 w-full">
              <span>{p.name}</span>
              <span class="text-nowrap">x {p.quantity}</span>
            </div>
            <div class="flex justify-end gap-1 w-full">
              <.live_component
                module={EveIndustrexWeb.MiniMarket}
                target_id={@reaction.type.type_id}
                selected_trade_hub={@selected_trade_hub}
                category={:product}
                id={"#{@id}_Product"}
                item={
                  %{
                    :category_id => p.category_id,
                    :name => p.name,
                    :type_id => p.type_id,
                    :price => @reaction.prices.products[p.type_id]
                  }
                }
                order_type={@order_type}
              />
            </div>
          </div>
        <% end %>
      </div>
      <div class="p-1 flex flex-col">
        <span class="text-ei-text-muted">Materials: </span>

        <%= for m <- @reaction.bp.activities.reaction.materials do %>
          <div class="flex p-1 gap-1 items-center">
            <div class="flex justify-between gap-1 w-full text-ei-text-muted ">
              <span>{m.name}</span>
              <span class="text-nowrap">x {m.quantity}</span>
            </div>
            <div class="flex justify-end gap-1 w-full">
              <.live_component
                module={EveIndustrexWeb.MiniMarket}
                target_id={@reaction.type.type_id}
                selected_trade_hub={@selected_trade_hub}
                category={:bp_materials}
                id={"#{@id}_BP_Materials_#{m.type_id}"}
                item={
                  %{
                    :category_id => m.category_id,
                    :name => m.name,
                    :type_id => m.type_id,
                    :price => @reaction.prices.materials[m.type_id]
                  }
                }
                order_type={@order_type}
              />
            </div>
          </div>
        <% end %>
      </div>

      <div class="p-1 flex flex-col">
        <span title="Total Materials Cost" class="text-ei-text-muted">Total: </span>
        <div class="flex p-1 gap-1 items-center">
          <%= if Enum.any?(@reaction.bp.activities.reaction.materials, fn m -> @reaction.prices.materials[m.type_id] == nil end) do %>
            <span class="text-ei-text-muted">Missing prices</span>
          <% else %>
            <span class="text-ei-text-muted">
              {Utils.format_with_coma(
                Enum.reduce(@reaction.bp.activities.reaction.materials, 0, fn m, acc ->
                  @reaction.prices.materials[m.type_id] * m.quantity + acc
                end)
              )} ISK
            </span>
          <% end %>
        </div>
      </div>
      <div class="flex flex-col">
        <div class="p-1 flex justify-between">
          <span title="Estimated Items Value" class="text-ei-text-muted">EIV: </span>
          <span class="text-ei-text-muted">{Utils.format_with_coma(@eiv)} ISK</span>
        </div>
        <div class="p-1 flex justify-between">
          <span title="Job installation Fee" class="text-ei-text-muted">Job Fee: </span>
          <span class="text-ei-text-muted">
            {Utils.format_with_coma(
              (@eiv * @system_cost_index)
              |> Market.Service.apply_fw_discount(@fw_upgrade)
            )} ISK
          </span>
        </div>
        <span class="text-ei-text-muted">Taxes: </span>
        <div class="p-1">
          <div class="p-1 flex justify-between">
            <span title="SSC Tax" class="text-ei-text-muted">SSC Tax: </span>
            <span class="text-ei-text-muted">{Utils.format_with_coma(@eiv * @ssc_tax)} ISK</span>
          </div>
          <div class="p-1 flex justify-between">
            <span title="Structure Tax" class="text-ei-text-muted">Structure Tax: </span>
            <span class="text-ei-text-muted">
              {Utils.format_with_coma(@eiv * @structure_tax)} ISK
            </span>
          </div>
          <div class="p-1 flex justify-between">
            <span title="Total Taxes" class="text-ei-text-muted">Total: </span>
            <span class="text-ei-text-muted">
              {Utils.format_with_coma(
                @eiv * @structure_tax + @eiv * @ssc_tax +
                  ((@eiv * @system_cost_index) |> Market.Service.apply_fw_discount(@fw_upgrade))
              )} ISK
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp apply_profitability_tag(profit) when is_number(profit) do
    cond do
      profit < 0 ->
        "bg-ei-critical shadow-sm shadow-ei-critical"

      profit > 0 ->
        "bg-ei-success shadow-md shadow-ei-success"

      true ->
        ""
    end
  end
end
