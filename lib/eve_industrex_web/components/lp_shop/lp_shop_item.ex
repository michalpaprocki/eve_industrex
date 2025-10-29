defmodule EveIndustrexWeb.LpShop.LpShopItem do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils

  def update(assigns,socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class={"flex gap-2 justify-between p-2 ring-2 ring-black/80 rounded-md "}>
        <div class="flex flex-col justify-between items-start w-[15%]">
            <div class="flex flex-col">
              <div class="flex gap-2">
                <%= case @offer.type.group.category_id do%>
                  <% 9 -> %>
                    <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{@offer.type.type_id}/bp?size=128"} />
                  <% 91 -> %>
                    <%= nil %>
                  <% _ -> %>
                  <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{@offer.type.type_id}/icon?size=128"} />
                <% end %>
                <span class="font-semibold"><%= @offer.type.name %></span>
              </div>
              <span> <%= if String.contains?(@offer.type.name, "Blueprint"), do: "Runs: #{@offer.quantity}", else: "Amount: #{@offer.quantity}"  %></span>
            </div>
          <div class="flex flex-col justify-center">
            <%= if String.contains?(@offer.type.name, "Blueprint") do %>
              <%= Enum.map(@offer.type.bp_products, fn bpp -> "Portion size #{bpp.portion_size}"  end) %>
              <%= for bpp <- @offer.type.bp_products do %>
                  <.live_component module={EveIndustrexWeb.LpShop.LpMiniMarket}  tax_rate={@tax_rate} category={:product} id={"#{@id}_Product"} item={%{:category_id => @offer.type.group.category_id,:name => bpp.name, :type_id => bpp.type_id}} orders={Enum.filter(@orders.result, fn order -> order.type_id == bpp.type_id  end)} />
              <% end %>
            <% else %>
              <.live_component module={EveIndustrexWeb.LpShop.LpMiniMarket} tax_rate={@tax_rate} category={:product} id={"#{@id}_Product"} item={%{:category_id => @offer.type.group.category_id,:name => @offer.type.name, :type_id => @offer.type.type_id}} orders={Enum.filter(@orders.result, fn order -> order.type_id == @offer.type.type_id end)}  />
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
        <div  class="flex flex-col w-[30%] ">
          <%= for ri <-@offer.req_items do %>
            <div class="flex gap-2 justify-between">
            <%= if ri != nil do %>
              <div class="p-1 flex gap-2 items-center justify-between">
                <span> <%= ri.type.name %></span>
                <span> <%= ri.quantity%></span>
              </div>
              <.live_component module={EveIndustrexWeb.LpShop.LpMiniMarket} tax_rate={@tax_rate} amount={ri.quantity} category={:materials}  id={"#{@id}_Materials_#{ri.type_id}"} item={%{:category_id => ri.type.group.category_id,:name =>ri.type.name, :type_id => ri.type.type_id}} orders={Enum.filter(@orders.result, fn order -> order.type_id == ri.type_id end)} />
            <% end %>
            </div>
          <% end %>
        </div>
        <div class="w-[15%]">
          <%= if String.contains?(@offer.type.name, "Blueprint") do %>
            <span>Production Materials Cost:</span>
            <.live_component module={EveIndustrexWeb.LpShop.LpBpMaterials} id={"#{@id}_BP_Materials"} bp_materials={@offer.type.products} orders={@orders.result} production_product={@offer.type.name} runs={@offer.quantity}/>
          <% end %>
        </div>

        <div class="flex w-[15%] justify-end">
        <%!-- refactor to allow sorting by isk / lp --%>
          <%= if String.contains?(@offer.type.name, "Blueprint") do %>
            <%!-- <.live_component module={EveIndustrexWeb.LpShop.IskOnLpReturn} id={Integer.to_string(i)<>"_#{@offer.type.type_id}_ISK_per_LP"} amount={@offer.quantity} portion_size={List.foldl(Enum.map(@offer.type.bp_products, fn bpp -> bpp.portion_size end), 0, fn x, acc -> acc + x end)} lp_cost={@offer.lp_cost} isk_cost={@offer.isk_cost}/> --%>
          <% else %>
            <%!-- <.live_component module={EveIndustrexWeb.LpShop.IskOnLpReturn} id={Integer.to_string(i)<>"_#{@offer.type.type_id}_ISK_per_LP"} amount={@offer.quantity} lp_cost={@offer.lp_cost} isk_cost={@offer.isk_cost}/> --%>
          <% end %>
        </div>
      </div>
    """
  end
end
