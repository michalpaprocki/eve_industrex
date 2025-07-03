defmodule EveIndustrexWeb.Market.Orders do
alias EveIndustrex.Utils
  use EveIndustrexWeb, :live_component

  def update(%{:data => []} = assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
  def update(assigns, socket) do
    sorted = if assigns.is_buy_list?, do: Enum.sort(assigns.data, &(&1.price > &2.price)), else: Enum.sort(assigns.data, &(&1.price < &2.price))
    {:ok, socket |> assign(assigns) |> assign(:data, sorted)}
  end

  def render(assigns) do
    ~H"""
    <div class="">
      <table class={"w-full text-sm table-fixed border-collapse"}>
        <thead>
            <%= if @is_buy_list? do %>
          <tr class="">
            <th class="w-[8%] sticky top-0 bg-stone-200"> region </th>
            <th class=" w-[10%] sticky top-0 bg-stone-200"> volume </th>
            <th class=" w-[12%] sticky top-0 bg-stone-200"> price </th>
            <th class=" w-[20%] sticky top-0 bg-stone-200"> location </th>
            <th class=" w-[4%] sticky top-0 bg-stone-200">range</th>
            <th class=" w-[8%] sticky top-0 bg-stone-200 truncate">min volume</th>
            <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-stone-200"> expires </th>
            <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-stone-200"> issued </th>
          </tr>
            <% else %>
            <tr class="">
              <th class="w-[8%] sticky top-0 bg-stone-200"> region </th>
              <th class=" w-[10%] sticky top-0 bg-stone-200"> volume </th>
              <th class=" w-[12%] sticky top-0 bg-stone-200"> price </th>
              <th class=" w-[30%] sticky top-0 bg-stone-200"> location </th>
              <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-stone-200"> expires </th>
              <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-stone-200"> issued </th>
          </tr>
            <% end %>
        </thead>
        <tbody class=" overflow-auto">
          <%= Enum.map(@data, fn o -> %>
            <tr class="px-2 font-sm hover:bg-black hover:text-white">
              <td class="pl-2 truncate"> <%= o.station.system.constellation.region.name %> </td>
              <td class="pl-2 text-end"> <%= Utils.format_with_coma(o.volume_remain) %> / <%= Utils.format_with_coma(o.volume_total) %> </td>
              <td class="pl-2 text-end truncate"> <%= Utils.format_with_coma(o.price) %> &nbsp;ISK </td>
              <td class="pl-2 text-start truncate">  <span class={apply_color_on_status(:erlang.float_to_binary(o.station.system.security_status, [decimals: 1]))}><%= :erlang.float_to_binary(o.station.system.security_status, [decimals: 1]) %></span>&nbsp;<%= o.station.name %> </td>
              <%= if @is_buy_list? do %>
              <td class="text-end">
                <%= if Regex.run(~r/[0-9]/, o.range), do: o.range<>" jumps", else: o.range %>
              </td>
              <% end %>
              <%= if @is_buy_list? do %>
              <td class="pl-2 text-end">
                <%=  o.min_volume %>
              </td>
              <% end %>
              <td class="pl-2 text-start"> <%= Utils.get_time_left(o.issued, o.duration) %> </td>
              <td class="pl-2 "> <%= Utils.calculate_time_difference(elem(DateTime.from_iso8601(o.issued), 1)) %> </td>
            </tr>
          <% end) %>
        </tbody>
      </table>
    </div>
    """
  end
  # not sure why but this wont work when called from another module
  defp apply_color_on_status(sec_status) do
    case sec_status do
      "1.0" ->
        "text-system1.0"
      "0.9" ->
        "text-system0.9"
      "0.8" ->
        "text-system0.8"
      "0.7" ->
        "text-system0.7"
      "0.6" ->
        "text-system0.6"
      "0.5" ->
        "text-system0.5"
      "0.4" ->
        "text-system0.4"
      "0.3" ->
        "text-system0.3"
      "0.2" ->
        "text-system0.2"
      "0.1" ->
        "text-system0.1"
      _ ->
        "text-system0.0"
    end
  end
end
