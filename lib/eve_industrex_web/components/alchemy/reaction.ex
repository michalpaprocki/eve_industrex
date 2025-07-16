defmodule EveIndustrexWeb.Alchemy.Reaction do
  use EveIndustrexWeb, :live_component

  def update_component(cid, %{:orders => orders}) do
    send_update(__MODULE__, id: cid, update: %{:orders => orders})
  end
  def update(%{:update => %{:orders => orders}}, socket) do
    {:ok, socket |> assign(:orders, orders)}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class="p-2 ring-2 ring-black my-2">
        <span class="font-bold text-lg"><%= elem(@data, 0) %></span>
        <%= for act <- elem(@data, 1).activities do %>
            <div class="flex flex-col gap-2 p-1">
              <div>
                <span class="font-semibold capitalize"> <%= hd(act.products).product.name %>&nbsp;:</span>
                <span class="indent-1"><%=  hd(act.products).amount %></span>
              </div>
               <div class="flex flex-col gap-2 items-between">
                     <span class="indent-1 font-semibold">Required Materials:</span>
                  <%= for m <- act.materials do %>
                   <div class="flex items-start justify-between">
                      <span class="indent-1">
                        <%= m.material_type.name %>  <%= m.amount %>
                      </span>
                      <div class="flex justify-between min-w-[20rem]">
                        <.live_component module={EveIndustrexWeb.Common.MiniMarket} material_cost_id={~s"#{@id}_#{m.material_type_id}_material_cost"} category={:reaction_material} id={~s"#{@id}_#{m.material_type_id}"}
                        item={%{:name => m.material_type.name, :type_id => m.material_type.type_id}} orders={Enum.filter(@orders.result, fn o -> o.type_id == m.material_type_id end)} />
                        <.live_component module={EveIndustrexWeb.Alchemy.MaterialCost} category={:material} id={~s"#{@id}_#{m.material_type_id}_material_cost"} amount={ m.amount} />
                      </div>
                    </div>
                  <% end %>
                       <.live_component module={EveIndustrexWeb.Alchemy.Total} profit_component_id={~s"#{@id}_reaction_profit"} id={~s"#{@id}_total"} />
                  <%= for p <- act.products do %>
                    <div class="flex gap-2 items-start justify-between">
                      <.live_component module={EveIndustrexWeb.Alchemy.Product} category={assigns.category} id={~s"#{@id}_product"} profit_component_id={~s"#{@id}_reaction_profit"} product={p} hub={@selected_trade_hub} orders={@orders} />
                    </div>
                  <% end %>
                  <div>
                      <.live_component module={EveIndustrexWeb.Alchemy.ReactionProfit} id={~s"#{@id}_reaction_profit"} />
                  </div>
            </div>

      </div>
        <% end %>

      </div>
    """
  end


end
