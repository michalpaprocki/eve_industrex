defmodule EveIndustrexWeb.Tools.ReactionsLive do
  alias Phoenix.LiveView.AsyncResult
  alias EveIndustrex.Industry
  alias EveIndustrex.Market
  alias EveIndustrex.Universe.Station
  alias EveIndustrexWeb.Layouts
  use EveIndustrexWeb, :live_view

  @form_types %{tax_rate: :float, selected_trade_hub: :integer, order_type: :string, filter: :string, sorter: :string}
  @order_types [%{name: "Sell", type: "sell"}, %{name: "Buy", type: "buy"}, %{name: "Buy -> Sell", type: "buy_sell"},  %{name: "Sell -> Buy", type: "sell_buy"}]
  @sorting_options [%{name: "Name ▲", type: "name_asc"}, %{name: "Name ▼", type: "name_desc"},%{name: "Group ▲", type: "group_asc"},%{name: "Group ▼", type: "group_desc"}, %{name: "Profit ▲", type: "profit_asc"}, %{name: "Profit ▼", type: "profit_desc"}]
  def mount(_params, _session, socket) do
    hubs =  Station.Query.get_trade_hubs()

    params = %{"selected_trade_hub" => hd(hubs).station_id, "order_type" => hd(@order_types).type, "filter" => "", "sorter" => hd(@sorting_options).type}
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
   {:ok, socket
   |> start_async(:get_formulas, fn -> Industry.Service.get_reactions_view() end)
   |> assign(:formulas, AsyncResult.loading())
   |> assign(:show_form, true)
   |> assign(:order_types, @order_types)
   |> assign(:sorting_options, @sorting_options)
   |> assign(:hubs, hubs)
   |> assign(:orders, nil)
   |> assign(:form, to_form(changeset, as: :reactions_form)) ,layout: {Layouts, :reactions}
  }

  end

  def render(assigns) do
    ~H"""
      <div class="text-xl font-semibold mb-10 h-30 flex flex-col gap-5 mt-10">
        <div class="flex gap-3 flex-col items-center top-20 left-0 w-full">
          <h1 class="">Reaction Browser</h1>
        </div>

      </div>
       <div class="flex justify-evenly gap-4 items-center flex-col">
        <details class="max-w-[95%] md:max-w-[75%] text-base font-semibold bg-black/70 text-white rounded-md transition">
          <summary class="p-4 hover:bg-white hover:text-black transition rounded-md">Want to filter?</summary>
            <ul class="p-2">
              You can filter items in the Search Item box:
              <li class="px-1">
                - search by item name.
              </li>
              <li class="px-1">
                - using the "&gt"(higher than) and "&lt"(lower than) symbols, this will return items that are higher or lower than the value specified, e.g.: >2000 will render items with ISK/LP ratio higher than 2000.
              </li>
              <li class="px-1">
                - providing a range will filter items with ISK/LP ratio within it, e.g.: [1000..2000] shows items with ISK/LP higher than 1000 and lower than 2000.
              </li>
              <li class="px-1">
                - inputing "++" will render only profitable offers.
              </li>
              <li class="px-1">
                - after filtering, you can filter additionally by item name using ":" e.g. >2000:blueprint will return all the blueprints with LP/ISK higher than 2000.
              </li>
            </ul>
        </details>
        <div role="note">
        Hint: You can click on a product or material price to adjust it to your liking.
        </div>
      </div>
      <div class={"flex w-full bg-black/70 backdrop-blur-sm top-20 left-0 sticky justify-between transition-all xl:justify-center shadow-sm shadow-black py-2 delay-0 duration-500 rounded-b-md z-10  #{if @show_form, do: "h-[12rem] lg:h-[8rem]", else: "h-0"}"} id={"lp_form_container"}>
        <div class="flex order-last gap-1 p-2 h-fit">
          <.button title="minimize or maximize" phx-click="toggle_form" type="button" aria-description="minimize or maximaze the form" class="z-10 top-24 h-10 w-10"> <%= if @show_form, do: "＿", else: "⬜" %> </.button>
          <.button title="scroll to top" phx-click={JS.dispatch("phx-scroll-to-top")} type="button" aria-description="scroll to top" class="z-10 top-24 h-10 w-10">▲</.button>
        </div>
          <.form for={@form} id={"reactions_form"} phx-change={"validate_form"} class={"overflow-hidden flex lg:flex-row flex-col gap-4 font-semibold"}>
            <div class="px-4 flex items-center gap-2">

              <.input class="" value={@form[:selected_trade_hub].value} field={@form[:selected_trade_hub]} options={Enum.map(@hubs, fn h -> [key: h.name, value: h.station_id] end)} label="Trade Hub:" type={"select"} id={"trade_hub_selection"}/>

              <.input class="" value={@form[:order_type].value} field={@form[:order_type]} options={Enum.map(@order_types, fn ot -> [key: ot.name, value: ot.type] end)}  label="Order type:" type={"select"} id={"order_type_selection"}/>
            </div>

            <div class="flex items-center lg:self-center self-end gap-2 justify-between px-4">
              <.input field={@form[:filter]} phx-debounce={1000} label="Search Item" type={"text"} class={"mt-0 min-w-[15ch] text-base #{if @formulas == nil , do: "cursor-not-allowed"}"} />
              <.input field={@form[:sorter]} label="Sort" type={"select"} class={"mt-0 min-w-[15ch] text-base #{if @formulas == nil , do: "cursor-not-allowed"}"}  options={Enum.map(@sorting_options, fn so -> [key: so.name, value: so.type] end)} value={@form[:sorter].value}/>
            </div>

            <.button phx-disable-with="Saving..." disabled={true} class={"hidden"}>
              submit
            </.button>
          </.form>
        </div>

      <div class="grid  lg:grid-cols-2 grid-cols-1 gap-2 min-w-[80%]">
        <%= cond do %>
        <%  @formulas == nil -> %>
          <% nil %>
        <% @formulas.loading || @orders.loading -> %>
         <div class="text-center text-xl font-bold my-20">
            Loading ...
            <div class={"mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
          </div>
        <% @formulas.ok? -> %>
        <%= for f <-sort(@formulas.result, @form[:sorter].value) do %>

          <.live_component module={EveIndustrexWeb.Reaction} selected_trade_hub={@form[:selected_trade_hub].value} order_type={@form[:order_type].value} reaction={f} id={f.type.type_id}/>
        <% end %>

        <% true -> %>

        <% end %>
      </div>
    """
  end

def handle_async(:get_formulas, {:ok, result}, socket) do
  %{:form => form} = socket.assigns
    params = %{selected_trade_hub: form[:selected_trade_hub].value}

    type_ids = Industry.Service.extract_reactions_type_ids(result)
   {:noreply, socket |> assign(:formulas, AsyncResult.ok(result))
      |> assign(:orders, AsyncResult.loading())
      |> start_async(:get_orders, fn -> Market.Service.get_initial_prices_for_view(params.selected_trade_hub, type_ids) end) }
end
def handle_async(:get_formulas, {:exit, reason}, socket) do
  {:noreply, socket}
end
def handle_async(:get_orders, {:ok, result}, socket) do
      %{:formulas => formulas, :form => form} = socket.assigns
      enriched_formulas = Industry.Service.enrich(formulas.result, result, form[:order_type].value)
    {:noreply, socket |> assign(:orders, AsyncResult.ok(result)) |> assign(:formulas, AsyncResult.ok(enriched_formulas)) }
end
# def handle_async(:get_orders, {:ok, result}, socket) do
#       %{:offers => offers, :form => form} = socket.assigns
#       offers = LoyaltyPoints.Service.enrich(offers.result, result, form[:order_type].value)
#       filtered_offers =
#       if form[:filter].value != nil do

#         filter_offers(offers, form[:filter].value)
#       else
#         nil
#       end
#     {:noreply, socket |> assign(:orders, AsyncResult.ok(result)) |> assign(:offers, AsyncResult.ok(offers)) |> assign(:filtered_offers, filtered_offers)}
# end

def handle_async(:get_orders, {:exit, reason}, socket) do
  {:noreply, socket}
end
def handle_event("validate_form", %{"reactions_form" => params}, socket) do

      %{:form => form, :formulas => formulas} = socket.assigns


      changeset =
        {%{}, @form_types}
        |> Ecto.Changeset.cast(params, Map.keys(@form_types))




        trade_hub = Ecto.Changeset.get_change(changeset, :selected_trade_hub)
        order_type = Ecto.Changeset.get_change(changeset, :order_type)
        filter = Ecto.Changeset.get_change(changeset, :filter)
        sorter = Ecto.Changeset.get_change(changeset, :sorter)

        cond do


          trade_hub != form[:selected_trade_hub].value ->
             path = "/tools/reactions/#{trade_hub}/#{form[:order_type].value}"

              type_ids = Industry.Service.extract_reactions_type_ids(formulas.result)
            {:noreply, socket |> assign(:form, to_form(changeset, as: :reactions_form)) |> start_async(:get_orders, fn -> Market.Service.get_initial_prices_for_view(trade_hub, type_ids) end) |> push_patch(to: path, replace: true)}

          order_type != form[:order_type].value ->
             path = "/tools/reactions/#{form[:selected_trade_hub].value}/#{order_type}"

              type_ids = Industry.Service.extract_reactions_type_ids(formulas.result)
            {:noreply, socket |> assign(:form, to_form(changeset, as: :reactions_form)) |> start_async(:get_orders, fn -> Market.Service.get_initial_prices_for_view(trade_hub, type_ids) end) |> push_patch(to: path, replace: true)}

          true ->


             path = "/tools/reactions/#{form[:selected_trade_hub].value}/#{form[:order_type].value}"


            {:noreply, socket |> assign(:form, to_form(changeset, as: :reactions_form))  |> assign(:formulas, formulas) |> push_patch(to: path, replace: true)}

          end
  end
  def handle_info({:update_price, :product, %{target_id: formula_id, price: price, type_id: stype_id}}, socket) do

    {:noreply, socket}
  end
  def handle_params(_unsigned_params, _uri, socket) do

    {:noreply, socket}
  end
  defp filter_formulas(formulas, string) do
    %{expression: expression, text_filter: text_filter} =


    formulas

  end
  defp sort(formulas, sorter) do
    formulas =
      formulas
      |> Map.values()

    cond do
      sorter == nil ->
        Enum.sort_by(formulas, & &1.type.name, :asc)
      sorter == "name_asc" ->
        Enum.sort_by(formulas, & &1.type.name, :asc)
      sorter == "name_desc" ->
        Enum.sort_by(formulas, & &1.type.name, :desc)
      sorter == "group_asc" ->
        Enum.sort_by(formulas, & {&1.type.group, &1.type.name}, :asc)
      sorter == "group_desc" ->
        Enum.sort_by(formulas, & {&1.type.group, &1.type.name}, :desc)
      sorter == "profit_asc" ->
        {valid, nils} =
          Enum.split_with(formulas, &(not is_nil(&1.profit)))

        Enum.sort_by(valid, & &1.profit, :asc) ++ nils
      sorter == "profit_desc" ->
        {valid, nils} =
          Enum.split_with(formulas, &(not is_nil(&1.profit)))

        Enum.sort_by(valid, & &1.profit, :desc) ++ nils

      true ->
        formulas
    end
  end
end
