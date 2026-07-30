defmodule EveIndustrexWeb.Market.Showcase do
  alias EveIndustrex.Universe.Type
  alias EveIndustrex.Market.AveragePrice
  alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component
  @image_url "https://images.evetech.net/types/"
  def update_component(cid, assigns) do
    send_update(__MODULE__, id: cid, update: %{:type_id => assigns})
  end

  def update(%{:update => %{:type_id => type_id}}, socket) do
    type = Type.Store.get_type_id_details(type_id)

    average_price = AveragePrice.Store.get_average_price(type_id)

    image_url =
      cond do
        String.contains?(type.name, "Blueprint copy") ->
          @image_url <> "#{type.type_id}/bpc?size=64"

        String.contains?(type.name, "Blueprint") ->
          @image_url <> "#{type.type_id}/bp?size=64"

        String.contains?(type.name, "Formula") ->
          @image_url <> "#{type.type_id}/bp?size=64"

        String.contains?(type.name, "SKIN") ->
          ""

        true ->
          @image_url <> "#{type.type_id}/icon?size=64"
      end

    {:ok,
     socket
     |> assign(:item, type)
     |> assign(:image_url, image_url)
     |> assign(:average_price, average_price)}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign(:item, nil)}
  end

  def render(%{:item => nil} = assigns) do
    ~H"""
    <div class="h-[25%] text-sm font-semibold truncate p-1 panel flex flex-col justify-center w-full">
      <h3 class="pl-2 font-semibold text-start">Search or select an item</h3>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col justify-center items-center p-1 h-[25%] panel w-full">
      <div class="h-16 min-w-16 m-1">
        <image class="h-16 w-16 rounded-md" alt="item icon" src={@image_url} />
      </div>
      <div class="flex text-sm flex-col p-1">
        <span>{@item.name}</span>
        <span>
          {if @item.packaged_volume,
            do: :erlang.float_to_binary(@item.packaged_volume, decimals: 2),
            else: :erlang.float_to_binary(@item.volume, decimals: 2)} m3
        </span>
        <span>
          Average Price: {if @average_price.average_price != nil,
            do: Utils.format_with_coma(@average_price.average_price),
            else: "N/A"} ISK
        </span>
      </div>
    </div>
    """
  end
end
