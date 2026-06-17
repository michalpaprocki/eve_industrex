defmodule EveIndustrexWeb.LpShop.LpShopItem do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils

  def update(assigns,socket) do

    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class={"flex gap-2 justify-between p-2 ring-2 ring-black/80 rounded-md mx-1"}>
        <div class="flex flex-col justify-between items-start w-[15%]">
            <div class="flex flex-col">
              <div class="flex gap-2">
                <%= case @offer.type.category_id do%>
                  <% 9 -> %>
                    <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{@offer.type.type_id}/bp?size=128"} />
                  <% 91 -> %>
                    <%= nil %>
                  <% _ -> %>
                  <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{@offer.type.type_id}/icon?size=128"} />
                <% end %>
                <span class="font-semibold break-all md:break-normal"><%= @offer.type.name %></span>
              </div>
              <span> <%= if String.contains?(@offer.type.name, "Blueprint"), do: "Runs: #{@offer.quantity}", else: "Amount: #{@offer.quantity}"  %></span>
            </div>
          <div class="flex flex-col justify-center">
            <%= if String.contains?(@offer.type.name, "Blueprint") and !String.contains?(@offer.type.name, "Crate") do %>
              <%= Enum.map(Enum.find(@offer.blueprint.activities, fn a -> a.activity == :manufacturing end).products, fn bpp -> "Portion size #{bpp.quantity}"  end) %>
              <%= for bpp <- Enum.find(@offer.blueprint.activities, fn a -> a.activity == :manufacturing end).products do %>
                  <.live_component module={EveIndustrexWeb.LpShop.LpMiniMarket} offer_id={@offer.offer_id} selected_trade_hub={@selected_trade_hub}  tax_rate={@tax_rate} category={:product} id={"#{@id}_Product"} item={%{:category_id => @offer.type.category_id,:name => bpp.name, :type_id => bpp.type_id, :price => @offer.prices.products[bpp.type_id]}} order_type={@order_type}/>

              <% end %>
            <% else %>
              <.live_component module={EveIndustrexWeb.LpShop.LpMiniMarket} offer_id={@offer.offer_id} selected_trade_hub={@selected_trade_hub} tax_rate={@tax_rate} category={:product} id={"#{@id}_Product"} item={%{:category_id => @offer.type.category_id,:name => @offer.type.name, :type_id => @offer.type.type_id, :price => @offer.prices.products[@offer.type.type_id]}} order_type={@order_type} />
            <% end %>
          </div>
        </div>

        <div class="flex flex-col gap-1 w-[8%]">
          <span>isk cost:</span>
          <span><%= Utils.format_with_coma(@offer.isk_cost) %></span>
          <span>lp cost:</span>
          <span><%= Utils.format_with_coma(@offer.lp_cost) %></span>
        </div>
        <div>

        </div>
        <div  class="flex flex-col w-[30%]">
          <%= for ri <-@offer.req_items do %>
            <div class="flex gap-2 justify-between">
            <%= if ri != nil do %>
              <div class="p-1 flex gap-2 items-center justify-between">
                <span> <%= ri.name %></span>
                <span> <%= ri.quantity%></span>
              </div>
                <.live_component module={EveIndustrexWeb.LpShop.LpMiniMarket} offer_id={@offer.offer_id} selected_trade_hub={@selected_trade_hub} tax_rate={@tax_rate} amount={ri.quantity} category={:req_item}  id={"#{@id}_req_item_#{ri.type_id}"} item={%{:category_id => ri.category_id,:name =>ri.name, :type_id => ri.type_id, :price => @offer.prices.req_items[ri.type_id]}} order_type={@order_type} />
            <% end %>
            </div>
          <% end %>
          <%= if Enum.all?(@offer.prices.req_items, fn {_type_id, price} -> price != nil end) and length(@offer.req_items) > 0 do %>
            <span class="self-end p-4 font-bold">total: <%=  Utils.format_with_coma(List.foldl(@offer.req_items, 0, fn ri, acc -> @offer.prices.req_items[ri.type_id] * ri.quantity + acc end)) %> ISK</span>
          <% end %>
        </div>
        <div class="w-[15%]">
          <%= if String.contains?(@offer.type.name, "Blueprint") and !String.contains?(@offer.type.name, "Crate") do %>
            <span>Production Materials Cost:</span>
              <.live_component module={EveIndustrexWeb.LpShop.LpBpMaterials} selected_trade_hub={@selected_trade_hub} id={"#{@id}_BP_Materials"} bp_materials={Enum.find(@offer.blueprint.activities, fn a -> a.activity == :manufacturing end).materials} bp_material_prices={@offer.prices.materials} production_product={@offer.type.name} runs={@offer.quantity} order_type={@order_type} offer_id={@offer.offer_id}/>
          <% end %>
        </div>

        <div class="flex w-[15%] justify-end">
        <%!-- refactor to allow sorting by isk / lp --%>

          <.live_component module={EveIndustrexWeb.LpShop.IskOnLpReturn} id={"#{@id}_#{@offer.type.type_id}_ISK_per_LP"} offer={@offer} order_type={@order_type} />

        </div>
      </div>
    """
  end
end
