defmodule EveIndustrexWeb.Reaction do
  use EveIndustrexWeb, :live_component
  alias EveIndustrex.Utils
  def update(assigns, socket) do
# to do components, unrefined reactions - alchemy - maybe split views, maybe separate here
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do

    ~H"""
      <div class="p-2 ring-2 ring-black rounded-md flex flex-col">
      <div class="flex gap-1 items-center">
        <img class="h-10 w-10 block" src={"https://images.evetech.net/types/#{@reaction.type.type_id}/bp?size=128"} />
        <span class="font-semibold"> <%= @reaction.type.name %> </span>
      </div>
        <div class="p-1 flex flex-col">
          <span class="font-semibold">Products: </span>

          <%= for p <- @reaction.bp.activities.reaction.products do %>
            <div class="flex p-1 gap-1 items-center">
              <div class="flex justify-between gap-1 w-full">
                <span><%= p.name %></span>
                <span><%= p.quantity %></span>
              </div>
              <div class="flex justify-end gap-1 w-full">
                <.live_component module={EveIndustrexWeb.MiniMarket} target_id={@reaction.type.type_id} selected_trade_hub={@selected_trade_hub} category={:product} id={"#{@id}_Product"} item={%{:category_id => p.category_id,:name => p.name, :type_id => p.type_id, :price => @reaction.prices.products[p.type_id]}} order_type={@order_type} />
              </div>
            </div>
          <% end %>
        </div>
        <div class="p-1 flex flex-col">
          <span class="font-semibold">Materials: </span>

          <%= for m <- @reaction.bp.activities.reaction.materials do %>
            <div class="flex p-1 gap-1 items-center">
              <div class="flex justify-between gap-1 w-full">
                <span><%= m.name %></span>
                <span><%= m.quantity %></span>
              </div>
              <div class="flex justify-end gap-1 w-full">
                <.live_component module={EveIndustrexWeb.MiniMarket} target_id={@reaction.type.type_id} selected_trade_hub={@selected_trade_hub} category={:bp_materials} id={"#{@id}_BP_Materials_#{m.type_id}"} item={%{:category_id => m.category_id,:name => m.name, :type_id => m.type_id, :price => @reaction.prices.materials[m.type_id]}} order_type={@order_type} />
              </div>
            </div>
          <% end %>
        </div>

        <div class="p-1 flex flex-col">
          <span class="font-semibold">Total: </span>
          <div class="flex p-1 gap-1 items-center">
            <%= if Enum.any?(@reaction.bp.activities.reaction.materials, fn m -> @reaction.prices.materials[m.type_id] == nil end) do %>
              <span class="font-semibold">Missing prices</span>
            <% else %>
            <span class="font-semibold"><%= Utils.format_with_coma(Enum.reduce(@reaction.bp.activities.reaction.materials, 0, fn m, acc -> @reaction.prices.materials[m.type_id] * m.quantity + acc end)) %></span>
            <% end %>

          </div>
        </div>

        <div class="p-1 flex flex-col">
          <span class="font-semibold">Profit: </span>
          <div class="flex p-1 gap-1 items-center">
            <%= if not is_nil(@reaction.profit) do %>
              <span class="font-semibold"><%= Utils.format_with_coma(@reaction.profit) %> ISK</span>
            <% else %>
              <span class="font-semibold">N/A </span>
            <% end %>
          </div>
        </div>
      </div>
    """
  end
end
