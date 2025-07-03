defmodule EveIndustrexWeb.Market.Showcase do
alias EveIndustrex.Types
  use EveIndustrexWeb, :live_component
@image_url "https://images.evetech.net/types/"
  def update_component(cid, assigns) do
    send_update(__MODULE__, id: cid, update: %{:type_id => assigns})
  end
  def update(%{:update => %{:type_id => type_id}}, socket) do
    item = Types.get_type(type_id)
    image_url =
    cond do
      String.contains?(item.name, "Blueprint copy") ->
        @image_url <> "#{item.type_id}/bpc?size=64"
        String.contains?(item.name, "Blueprint") ->
          @image_url <> "#{item.type_id}/bp?size=64"
        String.contains?(item.name, "Formula") ->
          @image_url <> "#{item.type_id}/bp?size=64"
        true ->
          @image_url <> "#{item.type_id}/icon?size=64"
    end
    {:ok, socket |> assign(:item, item) |> assign(:image_url, image_url)}
  end
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:item, nil)}
  end

  def render(%{:item => nil} = assigns) do
    ~H"""
      <div class="h-[25%] text-lg font-semibold truncate p-1">
        <h3 class="text-lg pl-2 font-semibold text-start">Search or select an item</h3>
      </div>
    """
  end
  def render(assigns) do
    ~H"""
      <div class="flex p-1 h-[25%]">
        <div class="h-16 min-w-16 m-1 text-black/70">
          <image class="h-16 w-16 rounded-md" alt="item's icon" src={@image_url} />
        </div>
      <div class="flex flex-col p-1">
        <span><%= @item.name %></span>
        <span><%= if @item.packaged_volume, do: :erlang.float_to_binary(@item.packaged_volume, [decimals: 2]), else: :erlang.float_to_binary(@item.volume, [decimals: 2]) %> m3</span>
      </div>


      </div>
    """
  end
end
