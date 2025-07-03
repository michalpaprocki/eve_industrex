 defmodule EveIndustrexWeb.Alchemy.Product do

  alias EveIndustrex.Materials
  use EveIndustrexWeb, :live_component
  @base_reprocess 0.5
  def update(%{:selected_skill_level => _level} = assigns, socket) do
      materials = Materials.get_materials(assigns.product_id)
    {:ok, socket |> assign(assigns) |> assign(:materials, materials) |> assign(:base_reprocess, @base_reprocess)}
  end
  def update(assigns, socket) do
    type_id = Enum.at(elem(hd(elem(Enum.at(elem(hd(elem(assigns.data, 1).activities), 1), 1), 1)), 0), 1)
    item_name = Enum.at(elem(hd(elem(Enum.at(elem(hd(elem(assigns.data, 1).activities), 1), 1), 1)), 0), 0)
    amount = elem(hd(elem(Enum.at(elem(hd(elem(assigns.data, 1).activities), 1), 1), 1)), 1)
    {:ok, socket |> assign(assigns) |> assign(:type_id, type_id) |> assign(:item_name, item_name) |> assign(:amount, amount)}
  end

  def render(%{:selected_skill_level => _level} = assigns) do
    ~H"""
    <div class="p-1 flex flex-col">
      <span class="font-semibold">Reprocessed into:</span>
      <%= for m <- @materials do %>
        <div class="flex items-center justify-between">
          <span> <%=elem(m,0).name%> <%=floor(elem(m,1) * (@base_reprocess * (1 + (@selected_skill_level * 0.02))))%> </span>
          <div class="flex gap-2 justify-between min-w-[20rem]">
            <.live_component module={EveIndustrexWeb.Market.MiniMarket} id={~s"#{@id}_#{elem(m,0).type_id}"} orders={Enum.filter(@orders.result, fn o -> o.type_id == elem(m,0).type_id end)} item={elem(m,0).name} />
            <.live_component module={EveIndustrexWeb.Alchemy.MaterialCost} id={~s"#{@id}_#{elem(m,0).type_id}_material_cost"} amount={floor(elem(m,1) * (@base_reprocess * (1 + (@selected_skill_level * 0.02))))}/>
          </div>
        </div>
      <% end %>
          <.live_component module={EveIndustrexWeb.Alchemy.Total} id={@id<>"_total"} />
    </div>
    """
  end
  def render(assigns) do
    ~H"""
    <div class="p-1 flex flex-col items-end">
      <div class="flex gap-2 justify-between min-w-[20rem]">
        <.live_component module={EveIndustrexWeb.Market.MiniMarket} id={~s"#{@id}_#{@type_id}"} orders={Enum.filter(@orders.result, fn o -> o.type_id == @type_id end)} item={@item_name} />
        <.live_component module={EveIndustrexWeb.Alchemy.MaterialCost} id={~s"#{@id}_#{@type_id}_material_cost"} amount={@amount}/>
      </div>
      <.live_component module={EveIndustrexWeb.Alchemy.Total} id={~s"#{@id}_total"}/>
    </div>
    """
  end
end
