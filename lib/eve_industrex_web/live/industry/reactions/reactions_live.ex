defmodule EveIndustrexWeb.Industry.ReactionsLive do
  alias Phoenix.LiveView.AsyncResult
  alias EveIndustrex.Industry
  alias EveIndustrex.Universe
  alias EveIndustrex.Market

  alias EveIndustrex.LiveParser
  alias EveIndustrexWeb.Layouts
  use EveIndustrexWeb, :live_view
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  # credo:disable-for-this-file Credo.Check.Refactor.Nesting
  @form_types %{
    structure_tax: :float,
    fw_upgrade: :integer,
    ssc_tax: :float,
    system_cost_index: :float,
    system_query: :string,
    tax_rate: :float,
    selected_trade_hub: :integer,
    order_type: :string,
    filter: :string,
    sorter: :string
  }
  @order_types [
    %{name: "Sell", type: "sell"},
    %{name: "Buy", type: "buy"},
    %{name: "Buy -> Sell", type: "buy_sell"},
    %{name: "Sell -> Buy", type: "sell_buy"}
  ]
  @sorting_options [
    %{name: "Name ▲", type: "name_asc"},
    %{name: "Name ▼", type: "name_desc"},
    %{name: "Profit ▲", type: "profit_asc"},
    %{name: "Profit ▼", type: "profit_desc"}
  ]
  def mount(params, _session, socket) do
    hubs = Universe.Service.get_trade_hubs()
    # read params
    path =
      cond do
        Map.has_key?(params, "hub_id") and Map.has_key?(params, "order_type") ->
          %{"hub_id" => params["hub_id"], "order_type" => params["order_type"]}

        Map.has_key?(params, "hub_id") ->
          %{"hub_id" => params["hub_id"]}

        true ->
          %{}
      end

    query =
      cond do
        Map.has_key?(params, "sort") and Map.has_key?(params, "query") ->
          %{"sort" => params["sort"], "query" => params["query"]}

        Map.has_key?(params, "sort") ->
          %{"sort" => params["sort"]}

        Map.has_key?(params, "query") ->
          %{"query" => params["query"]}

        true ->
          %{}
      end

    # params = %{"selected_corp" => select_corp(corps, path), "selected_trade_hub" => select_hub(hubs, path), "order_type" => select_order_type(@order_types, path), "filter" => maybe_apply_query(query["query"]), "sorter" => maybe_apply_sorting(query["sort"])}
    # changeset =
    # {%{}, @form_types}
    # |> Ecto.Changeset.cast(params, Map.keys(@form_types))
    params = %{
      "system_query" => nil,
      "system_cost_index" => 0.0,
      "selected_trade_hub" => select_hub(hubs, path),
      "order_type" => select_order_type(@order_types, path),
      "filter" => maybe_apply_query(query["query"]),
      "sorter" => maybe_apply_sorting(query["sort"]),
      "ssc_tax" => 0.04,
      "fw_upgrade" => 0,
      "structure_tax" => 0.0075
    }

    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    {:ok,
     socket
     |> start_async(:get_formulas, fn -> Industry.Production.Composer.reactions_view() end)
     |> assign(:formulas, AsyncResult.loading())
     |> assign(:show_form, true)
     |> assign(:order_types, @order_types)
     |> assign(:sorting_options, @sorting_options)
     |> assign(:hubs, hubs)
     |> assign(:orders, nil)
     |> assign(:filtered_formulas, nil)
     |> assign(:systems, [])
     |> assign(:page_title, "Reaction Profit Calculator | Eve Industrex")
     |> assign(
       :page_description,
       "Browse Eve Online reaction formulas, see profitability of each blueprint."
     )
     |> assign(:form, to_form(changeset, as: :reactions_form)), layout: {Layouts, :industry}}
  end

  def render(assigns) do
    ~H"""
    <div class="text-xl font-semibold mb-10 h-30 flex flex-col gap-5 mt-10">
      <div class="flex gap-3 flex-col items-center top-20 left-0 w-full">
        <h1 class="font-headers text-3xl">Reaction Calculator</h1>
      </div>
    </div>
    <div class="flex justify-evenly gap-4 items-center flex-col">
      <details class="max-w-[95%] md:max-w-[75%] text-sm font-semibold  rounded-md transition panel">
        <summary class="p-4 hover:bg-white hover:text-black transition rounded-md">Filtering</summary>
        <ul class="p-2">
          <li class="px-1">
            - search by item name.
          </li>
          <li class="px-1">
            - search by group name.
          </li>
          <li class="px-1">
            - using the "&gt"(higher than) and "&lt"(lower than) symbols will return items that are higher or lower than the value specified, e.g.: >2000 will render items with Profit ratio higher than 2000.
          </li>
          <li class="px-1">
            - providing a range will filter items with Profit ratio within it, e.g.: [1000..2000] shows items with Profit higher than 1000 and lower than 2000.
          </li>
          <li class="px-1">
            - inputing "++" will render only profitable offers.
          </li>
          <li class="px-1">
            - after filtering, you can filter additionally by item name or group using ":" e.g. >2000:blueprint will return all the blueprints with LP/ISK higher than 2000.
          </li>
        </ul>
      </details>
      <div role="note">
        Hint: You can click on a product or material price to adjust it to your liking.
      </div>
    </div>
    <div
      class={"semi-panel flex w-full bg-black/70 top-20 left-0 sticky justify-between transition-all xl:justify-center shadow-sm shadow-black delay-0 duration-500 rounded-b-md z-10  #{if @show_form, do: "h-[18rem] lg:h-[8rem]", else: "h-0"}"}
      id="lp_form_container"
    >
      <div class="flex order-last gap-1 p-2 h-fit">
        <.button
          title="minimize or maximize"
          phx-click="toggle_form"
          type="button"
          aria-description="minimize or maximaze the form"
          class="z-10 top-24 h-10 w-10"
        >
          {if @show_form, do: "＿", else: "⬜"}
        </.button>
        <.button
          title="scroll to top"
          phx-click={JS.dispatch("phx-scroll-to-top")}
          type="button"
          aria-description="scroll to top"
          class="z-10 top-24 h-10 w-10"
        >
          ▲
        </.button>
      </div>
      <.form
        for={@form}
        id="reactions_form"
        phx-change="validate_form"
        class="overflow-hidden flex lg:flex-row flex-col gap-4 font-semibold"
      >
        <div class="px-4 py-2 flex items-center gap-2">
          <.input
            class=""
            value={@form[:selected_trade_hub].value}
            field={@form[:selected_trade_hub]}
            options={Enum.map(@hubs, fn h -> [key: h.name, value: h.station_id] end)}
            label="Trade Hub:"
            type="select"
            id="trade_hub_selection"
          />

          <.input
            class=""
            value={@form[:order_type].value}
            field={@form[:order_type]}
            options={Enum.map(@order_types, fn ot -> [key: ot.name, value: ot.type] end)}
            label="Order type:"
            type="select"
            id="order_type_selection"
          />
        </div>

        <div class="flex items-center  gap-2 justify-start px-4">
          <.input
            field={@form[:filter]}
            phx-debounce={1000}
            label="Search Item"
            type="text"
            class={"mt-0 min-w-[15ch] text-base #{if @formulas == nil , do: "cursor-not-allowed"}"}
          />
          <.input
            field={@form[:sorter]}
            label="Sort"
            type="select"
            class={"mt-0 min-w-[15ch] text-base #{if @formulas == nil , do: "cursor-not-allowed"}"}
            options={Enum.map(@sorting_options, fn so -> [key: so.name, value: so.type] end)}
            value={@form[:sorter].value}
          />
        </div>
        <div class="px-4 py-2 flex items-center gap-2 ">
          <div class="flex flex-col">
            <.input
              class=""
              field={@form[:system_query]}
              options={[]}
              label="System:"
              type="search"
              phx-debounce={1000}
            />

            <%= if @form[:system_query].value != nil and @form[:system_query].value != "" do %>
              <div class="bg-black/70 flex flex-col w-[22ch] absolute top-0 lg:translate-y-28 translate-y-72  overflow-auto max-h-[20rem]">
                <%= for s <- @systems do %>
                  <span
                    class="hover:bg-white text-white hover:text-black p-1 w-full cursor-pointer"
                    phx-click="select_system"
                    phx-value-system_id={s.system_id}
                    phx-value-system_name={s.name}
                  >
                    {s.name}
                  </span>
                <% end %>
              </div>
            <% end %>
          </div>
          <.input
            field={@form[:system_cost_index]}
            label="System Cost Index:"
            min={0}
            max={25}
            step={0.01}
            type="number"
            value={@form[:system_cost_index].value}
          />

          <.input
            field={@form[:ssc_tax]}
            label="SSC Surcharge:"
            min={0}
            max={25}
            step={0.01}
            type="number"
            value={@form[:ssc_tax].value}
          />
          <.input
            field={@form[:fw_upgrade]}
            label="FW Upgrade Level:"
            min={0}
            max={5}
            step={1}
            type="number"
            value={@form[:fw_upgrade].value}
          />
          <.input
            field={@form[:structure_tax]}
            label="Structure Tax:"
            min={0}
            max={100}
            step={0.0001}
            type="number"
            value={@form[:structure_tax].value}
          />
        </div>
        <.button phx-disable-with="Saving..." disabled={true} class="hidden">
          submit
        </.button>
      </.form>
    </div>
    <div class="grid  lg:grid-cols-2 grid-cols-1 gap-2 min-w-[80%]">
      <%= cond do %>
        <% @formulas == nil -> %>
          <% nil %>
        <% @formulas.loading || @orders.loading  -> %>
          <div class="text-center col-span-full text-xl font-bold my-20">
            Loading ...
            <div class="mx-auto mt-20 h-14 w-14 rounded-full border-solid border-4 border-[black_transparent_black_transparent] animate-spin" />
          </div>
        <% @filtered_formulas != nil -> %>
          <%= for f <-sort(@filtered_formulas, @form[:sorter].value) do %>
            <.live_component
              module={EveIndustrexWeb.Reaction}
              selected_trade_hub={@form[:selected_trade_hub].value}
              order_type={@form[:order_type].value}
              reaction={f}
              id={f.type_id}
              system_cost_index={@form[:system_cost_index].value}
              ssc_tax={@form[:ssc_tax].value}
              fw_upgrade={@form[:fw_upgrade].value}
              structure_tax={@form[:structure_tax].value}
            />
          <% end %>
        <% @formulas.ok? -> %>
          <%= for f <-sort(@formulas.result, @form[:sorter].value) do %>
            <.live_component
              module={EveIndustrexWeb.Reaction}
              selected_trade_hub={@form[:selected_trade_hub].value}
              order_type={@form[:order_type].value}
              reaction={f}
              id={f.type_id}
              system_cost_index={@form[:system_cost_index].value}
              ssc_tax={@form[:ssc_tax].value}
              fw_upgrade={@form[:fw_upgrade].value}
              structure_tax={@form[:structure_tax].value}
            />
          <% end %>
        <% true -> %>
      <% end %>
    </div>
    """
  end

  def handle_async(:get_formulas, {:ok, result}, socket) do
    %{:form => form} = socket.assigns
    params = %{selected_trade_hub: form[:selected_trade_hub].value}

    type_ids =
      Enum.map(result, fn {_id, r} -> Industry.Production.Helper.extract_bp_type_ids(r) end)
      |> List.flatten()

    {:noreply,
     socket
     |> assign(:formulas, AsyncResult.ok(result))
     |> assign(:orders, AsyncResult.loading())
     |> start_async(:get_orders, fn ->
       Market.Cost.get_initial_prices_for_view(params.selected_trade_hub, type_ids)
     end)}
  end

  def handle_async(:get_formulas, {:exit, _reason}, socket) do
    {:noreply, socket}
  end

  def handle_async(:get_orders, {:ok, result}, socket) do
    %{:formulas => formulas, :form => form} = socket.assigns

    enriched_formulas =
      Market.Cost.enrich_bps(formulas.result, result, form[:order_type].value)

    filtered_formulas =
      if form[:filter].value != nil do
        filter_formulas(enriched_formulas, form[:filter].value)
      else
        nil
      end

    {:noreply,
     socket
     |> assign(:orders, AsyncResult.ok(result))
     |> assign(:formulas, AsyncResult.ok(enriched_formulas))
     |> assign(:filtered_formulas, filtered_formulas)}
  end

  def handle_async(:get_orders, {:exit, _reason}, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "select_system",
        %{"system_id" => system_id, "system_name" => sys_name},
        socket
      ) do
    id = String.to_integer(system_id)
    index = Industry.SystemCostIndex.Store.get_activity_system_cost_index(id, :reaction)
    %{:form => form} = socket.assigns

    params =
      Map.replace(form.params, "system_cost_index", elem(index, 2))
      |> Map.replace("system_query", sys_name)

    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    {:noreply,
     socket |> assign(:form, to_form(changeset, as: :reactions_form)) |> assign(:systems, [])}
  end

  def handle_event("toggle_form", _unsigned_params, socket) do
    %{:show_form => boolean} = socket.assigns
    {:noreply, socket |> assign(:show_form, !boolean)}
  end

  def handle_event("validate_form", %{"reactions_form" => params}, socket) do
    %{:form => form, :formulas => formulas, :systems => systems} = socket.assigns

    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    system_query = Ecto.Changeset.get_change(changeset, :system_query)
    trade_hub = Ecto.Changeset.get_change(changeset, :selected_trade_hub)
    order_type = Ecto.Changeset.get_change(changeset, :order_type)
    filter = Ecto.Changeset.get_change(changeset, :filter)
    sorter = Ecto.Changeset.get_change(changeset, :sorter)

    systems =
      cond do
        system_query != form[:system_query].value and system_query != nil ->
          Universe.Service.get_low_sec_systems(system_query)

        system_query == nil ->
          []

        true ->
          systems
      end

    cond do
      trade_hub != form[:selected_trade_hub].value ->
        path =
          "/industry/reactions/#{trade_hub}/#{form[:order_type].value}" <>
            LiveParser.maybe_compose_query(filter, sorter)

        type_ids =
          Enum.map(formulas.result, fn {_id, r} ->
            Industry.Production.Helper.extract_bp_type_ids(r)
          end)
          |> List.flatten()
          |> Enum.uniq()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: :reactions_form))
         |> start_async(:get_orders, fn ->
           Market.Cost.get_initial_prices_for_view(trade_hub, type_ids)
         end)
         |> assign(:systems, systems)
         |> push_patch(to: path, replace: true)}

      order_type != form[:order_type].value ->
        path =
          "/industry/reactions/#{form[:selected_trade_hub].value}/#{order_type}" <>
            LiveParser.maybe_compose_query(filter, sorter)

        type_ids =
          Enum.map(formulas.result, fn {_id, r} ->
            Industry.Production.Helper.extract_bp_type_ids(r)
          end)
          |> List.flatten()
          |> Enum.uniq()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: :reactions_form))
         |> start_async(:get_orders, fn ->
           Market.Cost.get_initial_prices_for_view(trade_hub, type_ids)
         end)
         |> assign(:systems, systems)
         |> push_patch(to: path, replace: true)}

      true ->
        path =
          "/industry/reactions/#{form[:selected_trade_hub].value}/#{form[:order_type].value}" <>
            LiveParser.maybe_compose_query(filter, sorter)

        filtered_formulas = filter_formulas(formulas.result, filter)

        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: :reactions_form))
         |> assign(:filtered_formulas, filtered_formulas)
         |> assign(:systems, systems)
         |> push_patch(to: path, replace: true)}
    end
  end

  def handle_info(
        {:update_price, type, %{target_id: formula_id, price: price, type_id: type_id}},
        socket
      ) do
    %{:formulas => formulas, :filtered_formulas => filtered_formulas} = socket.assigns

    if is_map(filtered_formulas) and Map.has_key?(filtered_formulas, formula_id) do
      filtered_update =
        Map.replace(
          filtered_formulas,
          formula_id,
          Market.Cost.update_blueprint_prices(
            Map.get(filtered_formulas, formula_id),
            type,
            price,
            type_id
          )
        )

      update =
        Map.replace(
          formulas.result,
          formula_id,
          Market.Cost.update_blueprint_prices(
            Map.get(formulas.result, formula_id),
            type,
            price,
            type_id
          )
        )

      {:noreply,
       socket
       |> assign(:formulas, Map.replace(formulas, :result, update))
       |> assign(:filtered_formulas, filtered_update)}
    else
      update =
        Map.replace(
          formulas.result,
          formula_id,
          Market.Cost.update_blueprint_prices(
            Map.get(formulas.result, formula_id),
            type,
            price,
            type_id
          )
        )

      {:noreply, socket |> assign(:formulas, Map.replace(formulas, :result, update))}
    end
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp filter_formulas(formulas, string) do
    %{expression: expression, text_filter: text_filter} =
      LiveParser.parse_filter(string)

    formulas
    |> LiveParser.apply_expression(:profit, expression)
    |> LiveParser.apply_text_filter(text_filter)
  end

  defp sort(formulas, sorter) do
    formulas =
      Enum.map(formulas, fn {_id, f} -> f end)

    cond do
      sorter == nil ->
        Enum.sort_by(formulas, & &1.name, :asc)

      sorter == "name_asc" ->
        Enum.sort_by(formulas, & &1.name, :asc)

      sorter == "name_desc" ->
        Enum.sort_by(formulas, & &1.name, :desc)

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

  defp select_hub(hubs, path) do
    if Map.has_key?(path, "hub_id") and
         Enum.any?(hubs, fn hub -> hub.station_id == String.to_integer(path["hub_id"]) end) do
      Enum.find(hubs, fn hub ->
        hub.station_id == String.to_integer(path["hub_id"])
      end).station_id
    else
      Enum.at(hubs, 0).station_id
    end
  end

  defp select_order_type(order_types, path) do
    if Map.has_key?(path, "order_type") and
         Enum.any?(order_types, fn type -> type.type == path["order_type"] end) do
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
end
