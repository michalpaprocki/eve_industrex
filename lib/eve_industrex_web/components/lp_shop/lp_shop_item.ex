defmodule EveIndustrexWeb.LpShop.LpShopItem do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  @moduledoc false
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class={"#{apply_profitability_on_card(@offer.isk_on_lp)} shard flex flex-col gap-2 text-sm justify-between p-3 border-surface-border border-1 bg-surface rounded-md mx-1 max-w-5xl"}>
      <div class="flex justify-between gap-2">
        <div class="flex flex-col justify-between items-start ">
          <div class="flex flex-col">
            <div class="flex gap-2">
              <%= case @offer.type.category_id do %>
                <% 9 -> %>
                  <img
                    class="h-10 w-10 block"
                    src={"https://images.evetech.net/types/#{@offer.type.type_id}/bp?size=128"}
                  />
                <% 91 -> %>
                  {nil}
                <% _ -> %>
                  <img
                    class="h-10 w-10 block"
                    src={"https://images.evetech.net/types/#{@offer.type.type_id}/icon?size=128"}
                  />
              <% end %>
              <div class="flex flex-col mb-5">
                <span class="font-semibold overflow-hidden text-ellipsis">{@offer.type.name}</span>
                <span class="text-ei-text-muted text-sm">{@offer.type.group}</span>
              </div>
            </div>
            <span>
              {if String.contains?(@offer.type.name, "Blueprint"),
                do: "Runs: #{@offer.quantity}",
                else: "Amount: #{@offer.quantity}"}
            </span>
          </div>
          <div class="flex flex-col justify-center">
            <%= if String.contains?(@offer.type.name, "Blueprint") and !String.contains?(@offer.type.name, "Crate") do %>
              {Enum.map(@offer.blueprint.activities.manufacturing.products, fn bpp ->
                "Portion size #{bpp.quantity}"
              end)}
              <%= for bpp <- @offer.blueprint.activities.manufacturing.products do %>
                <.live_component
                  module={EveIndustrexWeb.MiniMarket}
                  target_id={@offer.offer_id}
                  selected_trade_hub={@selected_trade_hub}
                  tax_rate={@tax_rate}
                  category={:product}
                  id={"#{@id}_Product"}
                  item={
                    %{
                      :category_id => @offer.type.category_id,
                      :name => bpp.name,
                      :type_id => bpp.type_id,
                      :price => @offer.prices.products[bpp.type_id]
                    }
                  }
                  order_type={@order_type}
                />
              <% end %>
            <% else %>
              <.live_component
                module={EveIndustrexWeb.MiniMarket}
                target_id={@offer.offer_id}
                selected_trade_hub={@selected_trade_hub}
                tax_rate={@tax_rate}
                category={:product}
                id={"#{@id}_Product"}
                item={
                  %{
                    :category_id => @offer.type.category_id,
                    :name => @offer.type.name,
                    :type_id => @offer.type.type_id,
                    :price => @offer.prices.products[@offer.type.type_id]
                  }
                }
                order_type={@order_type}
              />
            <% end %>
          </div>
        </div>
        <div class="flex justify-end">
          <%!-- refactor to allow sorting by isk / lp --%>

          <.live_component
            module={EveIndustrexWeb.LpShop.IskOnLpReturn}
            id={"#{@id}_#{@offer.type.type_id}_ISK_per_LP"}
            offer={@offer}
            order_type={@order_type}
          />
        </div>
      </div>

      <div class="flex flex-col gap-1 text-ei-text-muted">
        <div class="flex justify-between">
          <span>ISK Cost:</span>
          <span>{Utils.format_with_coma(@offer.isk_cost)} ISK</span>
        </div>
        <div class="flex justify-between">
          <span>LP Cost:</span>
          <span>{Utils.format_with_coma(@offer.lp_cost)} LP</span>
        </div>
      </div>

      <div class="flex flex-col">
        <span class="text-ei-text-muted">Required Items: </span>
        <%= for ri <-@offer.req_items do %>
          <div class="flex flex-col">
            <%= if ri != nil do %>
              <div class="flex justify-between">
                <div class="p-1 py-2 flex gap-2 items-center ">
                  <span class="text-ei-text-muted">{ri.name}</span>
                  <span class="text-nowrap">x {ri.quantity}</span>
                </div>
                <.live_component
                  module={EveIndustrexWeb.MiniMarket}
                  target_id={@offer.offer_id}
                  selected_trade_hub={@selected_trade_hub}
                  tax_rate={@tax_rate}
                  amount={ri.quantity}
                  category={:req_item}
                  id={"#{@id}_req_item_#{ri.type_id}"}
                  item={
                    %{
                      :category_id => ri.category_id,
                      :name => ri.name,
                      :type_id => ri.type_id,
                      :price => @offer.prices.req_items[ri.type_id]
                    }
                  }
                  order_type={@order_type}
                />
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if Enum.all?(@offer.prices.req_items, fn {_type_id, price} -> price != nil end) and length(@offer.req_items) > 0 do %>
          <div class="flex justify-between text-ei-text-muted py-2">
            <span class="">
              RI Total:
            </span>
            <span class="">
              {Utils.format_with_coma(
                List.foldl(@offer.req_items, 0, fn ri, acc ->
                  @offer.prices.req_items[ri.type_id] * ri.quantity + acc
                end)
              )} ISK
            </span>
          </div>
        <% end %>

        <%= if String.contains?(@offer.type.name, "Blueprint") and !String.contains?(@offer.type.name, "Crate") do %>
          <div class="flex justify-between">
            <span class="mt-4 text-ei-text-muted">Production Materials Cost:</span>
            <.live_component
              module={EveIndustrexWeb.LpShop.LpBpMaterials}
              selected_trade_hub={@selected_trade_hub}
              id={"#{@id}_BP_Materials"}
              bp_materials={@offer.blueprint.activities.manufacturing.materials}
              bp_material_prices={@offer.prices.materials}
              production_product={@offer.type.name}
              runs={@offer.quantity}
              order_type={@order_type}
              target_id={@offer.offer_id}
            />
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp apply_profitability_on_card(isk_on_lp) do
    cond do
      isk_on_lp > 2000 ->
        "shadow-sm shadow-ei-accent"

      isk_on_lp > 1000 ->
        "shadow-sm shadow-ei-success"

      true ->
        ""
    end
  end
end
