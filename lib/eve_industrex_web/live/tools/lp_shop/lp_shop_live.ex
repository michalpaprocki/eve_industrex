defmodule EveIndustrexWeb.Tools.LpShopLive do

  alias EveIndustrex.LoyaltyPoints
  alias EveIndustrex.Universe.Station
  alias EveIndustrex.LoyaltyPoints.CorpOffer
  alias EveIndustrex.Market
  alias EveIndustrex.LoyaltyPoints.NpcCorp
  alias EveIndustrexWeb.Layouts
  alias Phoenix.LiveView.AsyncResult
  use EveIndustrexWeb, :live_view

  @form_types %{tax_rate: :float, selected_corp: :integer, selected_trade_hub: :integer, order_type: :string, filter: :string, sorter: :string}
  @order_types [%{name: "Sell", type: "sell"}, %{name: "Buy", type: "buy"}, %{name: "Buy -> Sell", type: "buy_sell"},  %{name: "Sell -> Buy", type: "sell_buy"}]
  @sorting_options [%{name: "Name ▲", type: "name_asc"}, %{name: "Name ▼", type: "name_desc"}, %{name: "ISK/LP ▲", type: "isk_lp_asc"}, %{name: "ISK/LP ▼", type: "isk_lp_desc"}]


  def mount(params, _session, socket) do
    corps = NpcCorp.Query.corps_with_offers()
    hubs =  Station.Query.get_trade_hubs()

    path =
      cond do
        Map.has_key?(params, "hub_id") and Map.has_key?(params, "corp_id") && Map.has_key?(params, "order_type") ->
          %{"hub_id" => params["hub_id"], "corp_id" => params["corp_id"], "order_type" => params["order_type"]}
        Map.has_key?(params, "hub_id") and Map.has_key?(params, "corp_id") ->
          %{"hub_id" => params["hub_id"], "corp_id" => params["corp_id"]}
        Map.has_key?(params, "hub_id") ->
          %{"hub_id" => params["hub_id"]}
          true ->
            %{}
      end
    query =
      cond do
        Map.has_key?(params, "sort") and Map.has_key?(params, "query")->
          %{"sort" => params["sort"], "query" => params["query"]}
        Map.has_key?(params, "sort") ->
          %{"sort" => params["sort"]}
        Map.has_key?(params, "query") ->
          %{"query" => params["query"]}
          true ->
            %{}
      end


    params = %{"selected_corp" => select_corp(corps, path), "selected_trade_hub" => select_hub(hubs, path), "order_type" => select_order_type(@order_types, path), "filter" => maybe_apply_query(query["query"]), "sorter" => maybe_apply_sorting(query["sort"])}
    changeset =
    {%{}, @form_types}
    |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    {:ok, socket
     |> assign(:corps, corps)
     |> assign(:selected_corp, nil)
     |> assign(:offers, nil)
     |> assign(:initial_tax_rate, 0.0)
     |> assign(:tax_rate, nil)
     |> assign(:form, to_form(changeset, as: :lp_shop_form))
     |> assign(:show_form, true)
     |> assign(:orders, nil)
     |> assign(:filtered_offers, nil)
     |> assign(:order_types, @order_types)
     |> assign(:sorting_options, @sorting_options)
     |> maybe_start_async(params["selected_corp"])
     |> assign(:hubs, hubs) , layout: {Layouts, :lp_shop}

    }
  end

  def render(assigns) do

  ~H"""
      <div class="text-xl font-semibold mb-10 h-30 flex flex-col gap-5 mt-10">
        <div class="flex gap-3 flex-col items-center top-20 left-0 w-full">
          <h1 class=""><%= if @form[:selected_corp].value != nil, do:   Enum.find(@corps, fn c -> c.corp_id == @form[:selected_corp].value end).name %> Loyalty Points Shop Browser</h1>
          <%= if @form[:selected_corp].value != nil do %>
            <img class="w-80 h-80 blur-sm fixed -z-10" src={"https://images.evetech.net/corporations/#{@form[:selected_corp].value}/logo?size=256"} />
          <% end %>
        </div>
      <%= if Map.has_key?(assigns, :number_of_offers) do %>
        <span><%= @number_of_offers %> Offers Found</span>
      <% end %>
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
      <div class={"flex w-full bg-black/70 backdrop-blur-sm top-20 left-0 sticky justify-between transition-all xl:justify-center shadow-sm shadow-black delay-0 duration-500 rounded-b-md z-10  #{if @show_form, do: "h-[12rem] lg:h-[8rem]", else: "h-0"}"} id={"lp_form_container"}>
          <div class="flex order-last gap-1 p-2 h-fit">
          <.button title="minimize or maximize" phx-click="toggle_form" type="button" aria-description="minimize or maximaze the form" class="z-10 top-24 h-10 w-10"> <%= if @show_form, do: "＿", else: "⬜" %> </.button>
          <.button title="scroll to top" phx-click={JS.dispatch("phx-scroll-to-top")} type="button" aria-description="scroll to top" class="z-10 top-24 h-10 w-10">▲</.button>
          </div>
        <.form for={@form} id={"lp_shop_form"} phx-change={"validate_form"} class={"overflow-hidden flex lg:flex-row flex-col gap-4 font-semibold"}>
          <div class="px-4 flex items-center gap-2">
            <.input field={@form[:selected_corp]} label="Corporation Select" prompt={"Select Corporation..."} type={"select"} options={Enum.map(@corps, fn c -> [key: c.name, value: c.corp_id] end)} id={"corp_select"} class="mt-0 text-base"/>

            <.input class="" value={@form[:selected_trade_hub].value} field={@form[:selected_trade_hub]} options={Enum.map(@hubs, fn h -> [key: h.name, value: h.station_id] end)} label="Trade Hub:" type={"select"} id={"trade_hub_selection"}/>

            <.input class="" value={@form[:order_type].value} field={@form[:order_type]} options={Enum.map(@order_types, fn ot -> [key: ot.name, value: ot.type] end)}  label="Order type:" type={"select"} id={"order_type_selection"}/>
          </div>

          <div class="flex items-center lg:self-center self-end gap-2 justify-between px-4">
            <.input field={@form[:filter]} phx-debounce={1000} label="Search Item" type={"text"} class={"mt-0 min-w-[15ch] text-base #{if @offers == nil , do: "cursor-not-allowed"}"} />
            <.input field={@form[:sorter]} label="Sort" type={"select"} class={"mt-0 min-w-[15ch] text-base #{if @offers == nil , do: "cursor-not-allowed"}"}  options={Enum.map(@sorting_options, fn so -> [key: so.name, value: so.type] end)} value={@form[:sorter].value}/>
          </div>

          <.button phx-disable-with="Saving..." disabled={true} class={"hidden"}>
            submit
          </.button>
        </.form>

      </div>
      <div class="flex flex-col gap-2 min-w-[80%]">
        <%= cond do %>
        <%  @offers == nil -> %>
          <% nil %>
        <% @offers.loading || @orders.loading -> %>
         <div class="text-center text-xl font-bold my-20">
            Loading ...
            <div class={"mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin"}/>
          </div>
        <% @filtered_offers != nil -> %>

          <%= for {o, i} <- Enum.with_index(sort(@filtered_offers, @form[:sorter].value)) do %>
          <.live_component id={~s"#{i}_#{o.type.type_id}"} module={EveIndustrexWeb.LpShop.LpShopItem} selected_trade_hub={@form[:selected_trade_hub].value} offer={o} tax_rate={@initial_tax_rate} order_type={@form[:order_type].value} />
        <% end %>
        <% @offers.ok? -> %>
          <%= for {o, i} <- Enum.with_index(sort(@offers.result, @form[:sorter].value)) do %>
            <.live_component id={~s"#{i}_#{o.type.type_id}"} module={EveIndustrexWeb.LpShop.LpShopItem} selected_trade_hub={@form[:selected_trade_hub].value} offer={o} tax_rate={@initial_tax_rate} order_type={@form[:order_type].value} />
          <% end %>

        <% true -> %>

        <% end %>
      </div>
  """
  end

  def handle_async(:get_lp_offers, {:ok, result}, socket) do

    %{:form => form, :offers => _offers, :tax_rate => _tax_rate, :initial_tax_rate => _initial_tax_rate} = socket.assigns
     params = %{selected_corp: form[:selected_corp].value, selected_trade_hub: form[:selected_trade_hub].value}
    type_ids = LoyaltyPoints.Service.extract_offers_type_ids(result)

    {:noreply, socket |> assign(:offers,AsyncResult.ok(result))
      |> assign(:number_of_offers, length(Map.keys(result))) |> assign(:orders, AsyncResult.loading())
      |> start_async(:get_orders, fn -> Market.Service.get_initial_prices_for_lp_view(params.selected_trade_hub, type_ids) end) }
  end
    def handle_async(:get_orders, {:ok, result}, socket) do
      %{:offers => offers, :form => form} = socket.assigns
      offers = LoyaltyPoints.Service.enrich(offers.result, result, form[:order_type].value)
      filtered_offers =
      if form[:filter].value != nil do

        filter_offers(offers, form[:filter].value)
      else
        nil
      end
    {:noreply, socket |> assign(:orders, AsyncResult.ok(result)) |> assign(:offers, AsyncResult.ok(offers)) |> assign(:filtered_offers, filtered_offers)}
  end
  def handle_event("toggle_form", _unsigned_params, socket) do
    %{:show_form => boolean} = socket.assigns
    {:noreply, socket |> assign(:show_form, !boolean)}
  end
  def handle_event("validate_form", %{"lp_shop_form" => params}, socket) do

      %{:tax_rate => tax_rate, :initial_tax_rate => initial_tax_rate, :form => form, :offers => offers} = socket.assigns

      if params["selected_corp"] == "" do
        {:noreply, socket}
      else

      changeset =
        {%{}, @form_types}
        |> Ecto.Changeset.cast(params, Map.keys(@form_types))

      _new_tax_rate =
        if tax_rate == nil do
          initial_tax_rate
        else
          tax_rate
        end

        corp_id = Ecto.Changeset.get_change(changeset, :selected_corp)
        trade_hub = Ecto.Changeset.get_change(changeset, :selected_trade_hub)
        order_type = Ecto.Changeset.get_change(changeset, :order_type)
        filter = Ecto.Changeset.get_change(changeset, :filter)
        sorter = Ecto.Changeset.get_change(changeset, :sorter)


        cond do
          corp_id != form[:selected_corp].value ->
            path = "/tools/lp_shop/#{form[:selected_trade_hub].value}/#{corp_id}/#{form[:order_type].value}"<>maybe_compose_query(filter, sorter)


            {:noreply, socket |> assign(:form, to_form(changeset, as: :lp_shop_form)) |> assign(:offers, AsyncResult.loading()) |> start_async(:get_lp_offers, fn -> LoyaltyPoints.Service.get_lp_shop_view(corp_id) end) |> push_patch(to: path, replace: true)}


          trade_hub != form[:selected_trade_hub].value ->
             path = "/tools/lp_shop/#{trade_hub}/#{form[:selected_corp].value}/#{form[:order_type].value}"<>maybe_compose_query(filter, sorter)

              type_ids = LoyaltyPoints.Service.extract_offers_type_ids(offers.result)
            {:noreply, socket |> assign(:form, to_form(changeset, as: :lp_shop_form)) |> start_async(:get_orders, fn -> Market.Service.get_initial_prices_for_lp_view(trade_hub, type_ids) end) |> push_patch(to: path, replace: true)}

          order_type != form[:order_type].value ->
             path = "/tools/lp_shop/#{form[:selected_trade_hub].value}/#{form[:selected_corp].value}/#{order_type}"<>maybe_compose_query(filter, sorter)

              type_ids = LoyaltyPoints.Service.extract_offers_type_ids(offers.result)
            {:noreply, socket |> assign(:form, to_form(changeset, as: :lp_shop_form)) |> start_async(:get_orders, fn -> Market.Service.get_initial_prices_for_lp_view(trade_hub, type_ids) end) |> push_patch(to: path, replace: true)}

          true ->


             path = "/tools/lp_shop/#{form[:selected_trade_hub].value}/#{form[:selected_corp].value}/#{form[:order_type].value}"<>maybe_compose_query(filter, sorter)
             filtered_offers = filter_offers(offers.result, filter)

            {:noreply, socket |> assign(:form, to_form(changeset, as: :lp_shop_form))  |> assign(:filtered_offers, filtered_offers) |> push_patch(to: path, replace: true)}
          end
        end
  end

  def handle_params(_unsigned_params, _uri, socket) do

    {:noreply, socket}
  end
  def handle_info({:update_price, type, %{offer_id: offer_id, type_id: type_id, price: price}}, socket) do
    %{:offers => offers, :filtered_offers => filtered_offers} = socket.assigns
    if is_map(filtered_offers) and Map.has_key?(filtered_offers, offer_id) do
      filtered_update = Map.replace(filtered_offers, offer_id, LoyaltyPoints.Service.update_offer(Map.get(filtered_offers, offer_id), type, price, type_id))
      update = Map.replace(offers.result, offer_id, LoyaltyPoints.Service.update_offer(Map.get(offers.result, offer_id), type, price, type_id))

      {:noreply, socket |> assign(:offers, Map.replace(offers, :result, update)) |> assign(:filtered_offers, filtered_update)}
    else

      update = Map.replace(offers.result, offer_id, LoyaltyPoints.Service.update_offer(Map.get(offers.result, offer_id), type, price, type_id))

      {:noreply, socket |> assign(:offers, Map.replace(offers, :result, update))}
    end
  end
  def handle_info({:isk_on_lp, %{:offer_id => offer_id, :isk_on_lp => isk_on_lp}}, socket) do
    %{:offers => offers} = socket.assigns
    results = Enum.map(offers.result, fn o ->
      if o.offer_id == offer_id do
        Map.put(o, :isk_on_lp, isk_on_lp)
      else
        o
      end
    end)
    new_offers = Map.replace(offers, :result, results)

    {:noreply, socket |> assign(:offers, new_offers)}
  end
  defp filter_offers(offers, string) do
    %{expression: expression, text_filter: text_filter} =
      CorpOffer.Parser.parse_filter(string)

    offers
    |> CorpOffer.Parser.apply_expression(expression)
    |> CorpOffer.Parser.apply_text_filter(text_filter)
  end
  defp sort(offers, sorter) do
    offers =
      offers
      |> Map.values()

    cond do
      sorter == nil ->
        Enum.sort_by(offers, & &1.type.name, :asc)
      sorter == "name_asc" ->
        Enum.sort_by(offers, & &1.type.name, :asc)
      sorter == "name_desc" ->
        Enum.sort_by(offers, & &1.type.name, :desc)
      sorter == "isk_lp_asc" ->
        {valid, nils} =
          Enum.split_with(offers, &(not is_nil(&1.isk_on_lp)))

        Enum.sort_by(valid, & &1.isk_on_lp, :asc) ++ nils
      sorter == "isk_lp_desc" ->
        {valid, nils} =
          Enum.split_with(offers, &(not is_nil(&1.isk_on_lp)))

        Enum.sort_by(valid, & &1.isk_on_lp, :desc) ++ nils

      true ->
        offers
    end
  end
  defp select_hub(hubs, path) do

    if Map.has_key?(path, "hub_id") and Enum.any?(hubs, fn hub -> hub.station_id ==  String.to_integer(path["hub_id"]) end) do
      Enum.find(hubs, fn hub ->
        hub.station_id == String.to_integer(path["hub_id"])
      end).station_id
    else
      Enum.at(hubs,0).station_id
    end
  end
  defp select_corp(corps, path) do
    if Map.has_key?(path, "corp_id") and Enum.any?(corps, fn corp -> corp.corp_id ==  String.to_integer(path["corp_id"]) end) do
       Enum.find(corps, fn corp ->
        corp.corp_id == String.to_integer(path["corp_id"])
      end).corp_id
    else
      nil
    end
  end
  defp select_order_type(order_types, path) do
     if Map.has_key?(path, "order_type") and Enum.any?(order_types, fn type -> type.type ==  path["order_type"] end) do
       Enum.find(order_types, fn type ->
        type.type == path["order_type"]
      end).type
    else
      Enum.at(@order_types, 0).type
    end
  end
  defp maybe_apply_sorting(nil), do: hd(@sorting_options).type
  defp maybe_apply_sorting(sorting) do
   if Enum.any?(@sorting_options, fn so -> so.type == sorting end) do
     sorting
   else
    hd(@sorting_options).type
   end
  end
  defp maybe_apply_query(nil), do: ""
  defp maybe_apply_query(query) do
    if query == "profit" do
      "++"
    else
      query
    end

  end
  defp maybe_start_async(socket, nil), do: socket
  defp maybe_start_async(socket, selected_corp), do: assign(socket, :offers, AsyncResult.loading()) |> start_async(:get_lp_offers, fn -> LoyaltyPoints.Service.get_lp_shop_view(selected_corp) end)
  defp maybe_compose_query(filter, sorter) do

   cond do
    sorter != "" and filter == "++" ->
      "?sort=#{sorter}&query=profit"
    sorter != "" and filter != nil and filter != "" ->
      "?sort=#{sorter}&query=#{URI.encode_www_form(String.trim(filter))}"

    true ->
      "?sort=#{sorter}"
   end
  end
end
