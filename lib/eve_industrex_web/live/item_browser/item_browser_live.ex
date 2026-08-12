defmodule EveIndustrexWeb.ItemBrowserLive do
  alias EveIndustrex.SearchStore

  alias EveIndustrex.Industry.{
    BlueprintActivityMaterial,
    ReprocessMaterial,
    BlueprintActivityProduct,
    Blueprint
  }

  alias EveIndustrex.LoyaltyPoints.{CorpOffer, LpOffer, LpReqItem}
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Market.AveragePrice
  alias EveIndustrexWeb.Layouts
  alias EveIndustrex.Universe.Type
  @moduledoc false
  @image_url "https://images.evetech.net/types/"
  @form_types %{
    query: :string
  }
  def mount(%{"type_id" => type_id} = _params, _session, socket) do
    type = Type.Store.get_type_id_details(type_id)

    latest =
      SearchStore.get()
      |> Enum.map(fn {type_id, name} ->
        %{type_id: type_id, name: name}
      end)

    if type == nil do
      params = %{
        "query" => ""
      }

      changeset =
        {%{}, @form_types}
        |> Ecto.Changeset.cast(params, Map.keys(@form_types))

      {:ok,
       socket
       |> assign(:form, to_form(changeset, as: :item_search_form))
       |> assign(:latest, latest)
       |> assign(:results, [])
       |> assign(:type, nil)
       |> assign(:image_url, "")
       |> assign(:page_title, "Item with type id: #{type_id} not found | EveIndustrex")
       |> assign(:average_price, nil)
       |> assign(:not_found, true)
       |> assign(
         :page_description,
         "Search Eve Online Items - find relations, market data and more."
       ), layout: {Layouts, :item_browser}}
    else
      image_url =
        cond do
          String.contains?(type.name, "Blueprint copy") ->
            @image_url <> "#{type.type_id}/bpc?size=256"

          String.contains?(type.name, "Blueprint") and !String.contains?(type.name, "Crate") ->
            @image_url <> "#{type.type_id}/bp?size=256"

          String.contains?(type.name, "Formula") ->
            @image_url <> "#{type.type_id}/bp?size=256"

          String.contains?(type.name, "SKIN") ->
            ""

          true ->
            @image_url <> "#{type.type_id}/icon?size=256"
        end

      material_of =
        BlueprintActivityMaterial.Store.get_bps_by_material(type.type_id)
        |> Enum.sort_by(& &1.name, :asc)

      product_of = BlueprintActivityProduct.Store.get_bps_by_product(type.type_id)
      average_price = AveragePrice.Store.get_average_price(type.type_id)
      reprocess_mats = ReprocessMaterial.Store.get_type_reprocess_material(type.type_id)
      products = BlueprintActivityProduct.Store.get_product_by_bp(type_id)
      reprocessed_from = ReprocessMaterial.Store.get_type_by_reprocess_material(type.type_id)
      same_group = Type.Store.get_same_group(type.group_id)
      required_mats = Blueprint.Store.get_bp_materials(type.type_id)

      params = %{
        "query" => "#{type.name}"
      }

      SearchStore.save({type.type_id, type.name})
      offers = LpOffer.Store.get_offers_by_rewards(type.type_id)
      offer_required_item = LpReqItem.Store.get_offers_by_req_item(type.type_id)

      latest =
        SearchStore.get()
        |> Enum.map(fn {type_id, name} ->
          %{type_id: type_id, name: name}
        end)

      lp_corps =
        Enum.map(offers, fn {_k, o} ->
          CorpOffer.Store.get_corps_by_offer(o.offer_id)
        end)
        |> List.flatten()
        |> Enum.sort_by(& &1.name, :asc)

      changeset =
        {%{}, @form_types}
        |> Ecto.Changeset.cast(params, Map.keys(@form_types))

      {:ok,
       socket
       |> assign(:form, to_form(changeset, as: :item_search_form))
       |> assign(:page_title, "#{type.name} | EveIndustrex")
       |> assign(:results, [])
       |> assign(:latest, latest)
       |> assign(:type, type)
       |> assign(:image_url, image_url)
       |> assign(:page_title, "#{type.name} Details | EveIndustrex")
       |> assign(:average_price, average_price)
       |> assign(:not_found, false)
       |> assign(:material_of, material_of)
       |> assign(:reprocess_mats, reprocess_mats)
       |> assign(:selected_card, "")
       |> assign(:product_of, product_of)
       |> assign(:lp_corps, lp_corps)
       |> assign(:same_group, same_group)
       |> assign(:reprocessed_from, reprocessed_from)
       |> assign(:req_materials, required_mats)
       |> assign(:offer_required_item, offer_required_item)
       |> assign(:products, products)
       |> assign(
         :page_description,
         "Search Eve Online Items - find relations, market data and more."
       ), layout: {Layouts, :item_browser}}
    end
  end

  def mount(_params, _session, socket) do
    params = %{
      "query" => ""
    }

    latest =
      SearchStore.get()
      |> Enum.map(fn {type_id, name} ->
        %{type_id: type_id, name: name}
      end)

    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    {:ok,
     socket
     |> assign(:form, to_form(changeset, as: :item_search_form))
     |> assign(:page_title, "Eve Online Item Search | EveIndustrex")
     |> assign(:results, [])
     |> assign(:type, nil)
     |> assign(:latest, latest)
     |> assign(
       :page_description,
       "Search Eve Online Items - find relations, market data and more."
     ), layout: {Layouts, :item_browser}}
  end

  def render(%{:not_found => true} = assigns) do
    ~H"""
    <div class="mb-10 h-30 flex flex-col gap-5 mt-16">
      <div class="flex gap-3 flex-col items-center top-20 left-0 w-full">
        <h1 class="font-headers text-3xl">Eve Online Item Search</h1>
      </div>
    </div>

    <div class="flex justify-center p-12">
      Item not found.
    </div>
    <div class="bg-black/70 w-full flex justify-center items-center py-6 relative">
      <.form for={@form} id="item_search_form" phx-change="validate_form">
        <.input
          phx-debounce={1000}
          placeholder="Start typing to search..."
          field={@form[:query]}
          label="Item Search"
          value={@form[:query].value}
          prompt="Select Search for an item..."
          type="text"
          id="item_search"
        />
        <.button phx-disable-with="Saving..." disabled={true} class="hidden">
          submit
        </.button>
      </.form>
      <%= if @results != [] do %>
        <div class="flex flex-col gap-1 absolute translate-y-28 top-0 text-base w-full bg-black max-w-[500px] overflow-y-auto max-h-72 p-5">
          <%= for r <- @results do %>
            <.link class="hover:text-ei-hover" navigate={~p"/item/#{r.type_id}"}>
              {r.name}
            </.link>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="mb-10 h-30 flex flex-col gap-5 mt-16">
      <div class="flex gap-3 flex-col items-center top-20 left-0 w-full">
        <h1 class="font-headers text-3xl">Eve Online Item Search</h1>
      </div>
    </div>

    <div class="bg-black/70 w-full flex justify-center items-center py-6 relative">
      <.form for={@form} id="item_search_form" phx-change="validate_form">
        <.input
          phx-debounce={1000}
          placeholder="Start typing to search..."
          field={@form[:query]}
          label="Item Search"
          value={@form[:query].value}
          prompt="Select Search for an item..."
          type="text"
          id="item_search"
        />
        <.button phx-disable-with="Saving..." disabled={true} class="hidden">
          submit
        </.button>
      </.form>
      <%= if @results != [] do %>
        <div class="flex flex-col gap-1 absolute translate-y-28 top-0 text-base w-full bg-black max-w-[500px] overflow-y-auto max-h-72 p-5">
          <%= for r <- @results do %>
            <.link class="hover:text-ei-hover" navigate={~p"/item/#{r.type_id}"}>
              {r.name}
            </.link>
          <% end %>
        </div>
      <% end %>
    </div>

    <div class="flex flex-col justify-center mx-auto mt-10 max-w-[1400px]">
      <%= if @type do %>
        <h2 class="text-center text-headers my-10 text-2xl">{@type.name} Details</h2>
        <div class="flex flex-col gap-1">
          <.live_component
            module={EveIndustrexWeb.ItemBrowser.Item}
            id={@type.type_id}
            type={@type}
            average_price={@average_price}
            image_url={@image_url}
          />
          <div class="p-8 panel">
            <div>
              <div class="flex bg-black p-8 rounded-md gap-2 text-nowrap flex-wrap">
                <%= if @type.category_id == 9 do %>
                  <.button
                    class={"#{if @selected_card == "products", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                    phx-click="select_card"
                    phx-value-card="products"
                  >
                    BP Products: {length(@products)}
                  </.button>
                  <.button
                    class={"#{if @selected_card == "req_materials", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                    phx-click="select_card"
                    phx-value-card="req_materials"
                  >
                    BP Activities
                  </.button>
                <% end %>
                <.button
                  class={"#{if @selected_card == "material_for", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="select_card"
                  phx-value-card="material_for"
                >
                  Material for: {length(@material_of)}
                </.button>
                <.button
                  class={"#{if @selected_card == "reprocess_mats", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="select_card"
                  phx-value-card="reprocess_mats"
                >
                  Reprocesses into: {length(@reprocess_mats)}
                </.button>
                <.button
                  class={"#{if @selected_card == "reprocessed_from", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="select_card"
                  phx-value-card="reprocessed_from"
                >
                  Reprocessed From: {length(@reprocessed_from)}
                </.button>
                <.button
                  class={"#{if @selected_card == "lp_corps", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="select_card"
                  phx-value-card="lp_corps"
                >
                  LP Reward From: {length(@lp_corps)}
                </.button>
                <.button
                  class={"#{if @selected_card == "required_item", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="select_card"
                  phx-value-card="required_item"
                >
                  Required for LP offer: {length(@offer_required_item)}
                </.button>
                <.button
                  class={"#{if @selected_card == "product_of", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="select_card"
                  phx-value-card="product_of"
                >
                  Product Of: {length(@product_of)}
                </.button>

                <.button
                  class={"#{if @selected_card=="same_group", do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="select_card"
                  phx-value-card="same_group"
                >
                  Same Group: {length(@same_group)}
                </.button>
              </div>

              <div>
                <%= cond do %>
                  <% @selected_card == "material_for" -> %>
                    <div class="flex flex-col p-8">
                      <%= for m <- @material_of do %>
                        <.link class="hover:text-ei-hover transition" navigate={"/item/#{m.type_id}"}>
                          {m.name}
                        </.link>
                      <% end %>
                    </div>
                  <% @selected_card == "req_materials" -> %>
                    <div class="flex flex-col p-8">
                      <%= for r <- @req_materials do %>
                        <%= if r.materials != [] do %>
                          <span class="capitalize my-2">Activity: {r.activity}</span>
                          <div class="p-1 flex flex-col gap-1">
                            <%= for m <- r.materials do %>
                              <div class="flex flex-col">
                                <.link
                                  class="hover:text-ei-hover transition"
                                  navigate={"/item/#{m.type_id}"}
                                >
                                  {m.name}
                                </.link>
                                <span>Amount: {m.quantity}</span>
                              </div>
                            <% end %>
                          </div>
                        <% end %>
                      <% end %>
                    </div>
                  <% @selected_card == "reprocess_mats" -> %>
                    <div class="flex flex-col p-8">
                      <%= for r <- @reprocess_mats do %>
                        <div>
                          <.link
                            class="hover:text-ei-hover transition"
                            navigate={"/item/#{r.material_type_id}"}
                          >
                            {r.name}
                          </.link>

                          <%= if r.quantity do %>
                            <span>{r.quantity}</span>
                          <% end %>

                          <%= if r.min_quantity do %>
                            <span>{r.min_quantity}</span>
                          <% end %>

                          <%= if r.max_quantity do %>
                            <span>{r.max_quantity}</span>
                          <% end %>
                        </div>
                      <% end %>
                    </div>
                  <% @selected_card == "reprocessed_from" -> %>
                    <div class="flex flex-col p-8">
                      <%= for r <- @reprocessed_from do %>
                        <.link class="hover:text-ei-hover transition" navigate={"/item/#{r.type_id}"}>
                          {r.name}
                        </.link>
                      <% end %>
                    </div>
                  <% @selected_card == "lp_corps" -> %>
                    <div class="flex flex-col p-8">
                      <%= for o <- @lp_corps do %>
                        <.link
                          class="hover:text-ei-hover transition"
                          navigate={"/market/lp_shop/60003760/#{o.corp_id}/sell?sort=name_asc&query=#{URI.encode(@type.name)}"}
                        >
                          {o.name}
                        </.link>
                      <% end %>
                    </div>
                  <% @selected_card == "required_item" -> %>
                    <div class="flex flex-col p-8">
                      <%= for ri <- @offer_required_item do %>
                        <.link class="hover:text-ei-hover transition" navigate={"/item/#{ri.type_id}"}>
                          {ri.name}
                        </.link>
                      <% end %>
                    </div>
                  <% @selected_card =="same_group" -> %>
                    <div class="flex flex-col p-8">
                      <%= for s <- @same_group do %>
                        <.link class="hover:text-ei-hover transition" navigate={"/item/#{s.type_id}"}>
                          {s.name}
                        </.link>
                      <% end %>
                    </div>
                  <% @selected_card == "product_of" -> %>
                    <div class="flex flex-col p-8">
                      <%= for p <- @product_of do %>
                        <.link class="hover:text-ei-hover transition" navigate={"/item/#{p.type_id}"}>
                          {p.name}
                        </.link>
                      <% end %>
                    </div>
                  <% @selected_card == "products" -> %>
                    <div class="flex flex-col p-8">
                      <%= for p <- @products do %>
                        <.link class="hover:text-ei-hover transition" navigate={"/item/#{p.type_id}"}>
                          {p.name}
                        </.link>
                      <% end %>
                    </div>
                  <% true -> %>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      <% end %>
      <%= if @latest do %>
        <div class="flex gap-1 flex-col justify-center items-center p-2 my-14">
          <h3>Latest searches:</h3>
          <div class="flex flex-col gap-1 mt-4 text-sm">
            <%= for l <- @latest do %>
              <.link
                class="hover:text-ei-hover transition"
                navigate={"/item/#{l.type_id}"}
                class="p-1 hover:text-ei-hover"
              >
                {l.name}
              </.link>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("validate_form", %{"item_search_form" => params}, socket) do
    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    if String.length(params["query"]) > 2 do
      types =
        Type.Store.search(params["query"])
        |> Enum.map(fn {type_id, type} ->
          %{type_id: type_id, name: type.name}
        end)

      {:noreply,
       socket
       |> assign(:form, to_form(changeset, as: :item_search_form))
       |> assign(:results, types)}
    else
      {:noreply,
       socket |> assign(:form, to_form(changeset, as: :item_search_form)) |> assign(:results, [])}
    end
  end

  def handle_event("select_card", %{"card" => card}, socket) do
    {:noreply, socket |> assign(:selected_card, card)}
  end
end
