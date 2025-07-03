defmodule EveIndustrexWeb.Alchemy.Reaction do
  use EveIndustrexWeb, :live_component

  def update_component(cid, %{:orders => orders}) do
    send_update(__MODULE__, id: cid, update: %{:orders => orders})
  end
  def update(%{:update => %{:orders => orders}}, socket) do
    {:ok, socket |> assign(:orders, orders)}
  end
   def update(%{:selected_skill_level => level} = assigns, socket) when is_integer(level) do
    {:ok, socket |> assign(assigns)}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def render(assigns) do
    ~H"""
      <div class="p-2 ring-2 ring-black my-2">
        <span class="font-bold text-lg"><%= elem(@data, 0) %></span>
        <%= for a <- elem(@data, 1).activities do %>
          <%= for act <- elem(a, 1) do %>
            <div class="flex flex-col p-1">
              <span class="font-semibold capitalize"> <%= elem(act, 0) %>&nbsp;:</span>
              <%= cond do %>
                <%  is_number(elem(act, 1)) -> %>
                  <span class="indent-1"><%=  elem(act, 1) %></span>
                <% elem(act, 0) == "materials" -> %>
                  <%= for x <- elem(act, 1) do %>
                    <div class="flex gap-2 items-center justify-between">
                      <span class="indent-1">
                        <%= hd(elem(x, 0)) %>  <%= elem(x, 1) %>
                      </span>
                      <div class="flex gap-2 justify-between min-w-[20rem]">
                        <.live_component module={EveIndustrexWeb.Market.MiniMarket} id={~s"#{@id}_#{Enum.at(elem(x,0), 1)}"} item={hd(elem(x, 0))} orders={Enum.filter(@orders.result, fn o -> o.type_id == Enum.at(elem(x, 0), 1)end)} />
                        <.live_component module={EveIndustrexWeb.Alchemy.MaterialCost} id={~s"#{@id}_#{Enum.at(elem(x,0), 1)}_material_cost"} amount={elem(x, 1)} />
                      </div>
                    </div>
                  <% end %>
                    <.live_component module={EveIndustrexWeb.Alchemy.Total} id={~s"#{@id}_total"} data={elem(@data, 1).activities} />
                  <% true ->  %>
                    <%= for x <- elem(act, 1) do %>
                      <span class="indent-1">
                        <%= hd(elem(x, 0)) %>  <%= elem(x, 1)%>
                      </span>
                      <%= if elem(act, 0) == "products" && String.contains?(String.downcase(elem(@data, 0)), "unrefined") do %>
                        <.live_component module={EveIndustrexWeb.Alchemy.Product} id={~s"#{@id}_product"} product_id={Enum.at(elem(x, 0), 1)} selected_skill_level={@selected_skill_level} hub={@selected_trade_hub} orders={@orders} data={@data}/>
                      <% end %>
                      <%= if elem(act, 0) == "products" && !String.contains?(String.downcase(elem(@data, 0)), "unrefined") do %>
                       <.live_component module={EveIndustrexWeb.Alchemy.Product} id={~s"#{@id}_product"} product_id={Enum.at(elem(x, 0), 1)} hub={@selected_trade_hub} orders={@orders} data={@data}/>
                      <% end %>
                  <% end %>
                <% end %>
                  <div>
            </div>
      </div>
          <% end %>
        <% end %>

      </div>
    """
  end


end
