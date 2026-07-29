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
      <table class={"w-full table-fixed border-collapse text-xs text-ei-text text-nowrap text-ellipsis"}>
        <thead>
            <%= if @is_buy_list? do %>
          <tr class="">
            <th class="w-[8%] sticky top-0 bg-ei-bg"> region </th>
            <th class=" w-[10%] sticky top-0 bg-ei-bg"> quantity </th>
            <th class=" w-[12%] sticky top-0 bg-ei-bg"> price </th>
            <th class=" w-[20%] sticky top-0 bg-ei-bg"> location </th>
            <th class=" w-[6%] sticky top-0 bg-ei-bg">range</th>
            <th class=" w-[6%] sticky top-0 bg-ei-bg truncate">min volume</th>
            <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-ei-bg"> expires </th>
            <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-ei-bg"> issued </th>
          </tr>
            <% else %>
            <tr class="">
              <th class="w-[8%] sticky top-0 bg-ei-bg"> region </th>
              <th class=" w-[10%] sticky top-0 bg-ei-bg"> quantity </th>
              <th class=" w-[12%] sticky top-0 bg-ei-bg"> price </th>
              <th class=" w-[30%] sticky top-0 bg-ei-bg"> location </th>
              <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-ei-bg"> expires </th>
              <th class="border-1 border-solid border-black/20 w-[7%] sticky top-0 bg-ei-bg"> issued </th>
          </tr>
            <% end %>
        </thead>
        <tbody class="overflow-auto bg-black/70">
          <%= Enum.map(@data, fn o -> %>
            <%= if o.location != nil do %>
            <tr class="px-2 font-sm hover:bg-ei-hover hover:text-white">
              <td class="px-[0.5rem] truncate border-r-[1px] border-stone-800"> <%= o.location.region %> </td>
              <td class="px-[0.5rem] text-end" border-r-[1px] border-stone-800> <%= Utils.format_with_coma(o.volume_remain) %></td>
              <td class="px-[0.5rem] text-end truncate border-r-[1px] border-stone-800"> <%= Utils.format_with_coma(o.price) %> &nbsp;ISK </td>
              <td class="px-[0.5rem] text-start truncate border-r-[1px] border-stone-800">  <span class={apply_color_on_status(:erlang.float_to_binary(o.location.security_status, [decimals: 1]))}><%= :erlang.float_to_binary(o.location.security_status, [decimals: 1]) %></span>&nbsp;<%= o.location.name %> </td>
              <%= if @is_buy_list? do %>
              <td class="text-end border-r-[1px] border-stone-800 truncate">
                <%= if Regex.run(~r/[0-9]/, o.range), do: o.range<>" jumps", else: o.range %>
              </td>
              <% end %>
              <%= if @is_buy_list? do %>
              <td class="px-[0.5rem] text-end border-r-[1px] border-stone-800 truncate">
                <%=  o.min_volume %>
              </td>
              <% end %>
              <td class="px-[0.5rem] text-start border-r-[1px] border-stone-800"> <%= Utils.get_time_left(o.issued, o.duration) %> </td>
              <td class="px-[0.5rem]"> <%= Utils.calculate_time_difference(o.issued) %> </td>
            </tr>
            <% end %>
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
