defmodule EveIndustrexWeb.ItemBrowserLive do
  alias EveIndustrex.Industry.BlueprintActivityMaterial
  alias EveIndustrex.Industry.ReprocessMaterial
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Market.AveragePrice
  alias EveIndustrexWeb.Layouts
  alias EveIndustrex.Universe.Type

  @image_url "https://images.evetech.net/types/"
  @form_types %{
    query: :string
  }
  def mount(%{"type_id" => type_id} = _params, _session, socket) do
    type = Type.Store.get_type_id_details(type_id)

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

      average_price = AveragePrice.Store.get_average_price(type.type_id)
      reprocess_mats = ReprocessMaterial.Store.get_type_reprocess_material(type_id)

      params = %{
        "query" => "#{type.name}"
      }

      lp_rewards = []

      changeset =
        {%{}, @form_types}
        |> Ecto.Changeset.cast(params, Map.keys(@form_types))

      {:ok,
       socket
       |> assign(:form, to_form(changeset, as: :item_search_form))
       |> assign(:page_title, "#{type.name} | EveIndustrex")
       |> assign(:results, [])
       |> assign(:type, type)
       |> assign(:image_url, image_url)
       |> assign(:page_title, "#{type.name} Details | EveIndustrex")
       |> assign(:average_price, average_price)
       |> assign(:not_found, false)
       |> assign(:material_of, material_of)
       |> assign(:reprocess_mats, reprocess_mats)
       |> assign(:lp_rewards, lp_rewards)
       |> assign(:show_recipes, false)
       |> assign(:show_reprocess, false)
       |> assign(:show_lp_rewards, false)
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

    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    {:ok,
     socket
     |> assign(:form, to_form(changeset, as: :item_search_form))
     |> assign(:page_title, "Eve Online Item Search | EveIndustrex")
     |> assign(:results, [])
     |> assign(:type, nil)
     |> assign(:material_of, nil)
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
            <div class="">
              <div class="flex bg-black p-8 rounded-md gap-2">
                <.button
                  class={"#{if @show_recipes, do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="toggle_recipes"
                >
                  Recipes: {length(@material_of)}
                </.button>
                <.button
                  class={"#{if @show_reprocess, do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="toggle_reprocess"
                >
                  Reprocess: {length(@reprocess_mats)}
                </.button>
                <.button
                  class={"#{if @show_lp_rewards, do: "bg-ei-accent hover:bg-ei-hover", else: "bg-surface hover:bg-ei-hover"}"}
                  phx-click="toggle_lp_rewards"
                >
                  LP Rewards: {length(@lp_rewards)}
                </.button>
              </div>
              <%= if @show_recipes do %>
                <div class="flex flex-col p-8">
                  <%= for m <- @material_of do %>
                    <span>{m.name}</span>
                  <% end %>
                </div>
              <% end %>
              <%= if @show_reprocess do %>
                <div class="flex flex-col p-8">
                  <%= for r <- @reprocess_mats do %>
                    <div>
                      <span>{r.name}</span>

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
              <% end %>
            </div>
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

  def handle_event("toggle_recipes", _unsigned_params, socket) do
    {:noreply, socket |> assign(:show_recipes, !socket.assigns.show_recipes)}
  end

  def handle_event("toggle_reprocess", _unsigned_params, socket) do
    {:noreply, socket |> assign(:show_reprocess, !socket.assigns.show_reprocess)}
  end
end
