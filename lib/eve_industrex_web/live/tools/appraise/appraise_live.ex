defmodule EveIndustrexWeb.Tools.AppraiseLive do
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.AppraisalParser
  alias EveIndustrex.Market
  alias EveIndustrex.Types
  def mount(_params, _session, socket) do

    {:ok, socket |> assign(:types, [])}
  end

  def render(assigns) do
    ~H"""
      <section>
        <h1 class="text-xl font-bold">
        Eve Online Item Appraisal
        </h1>
        <div class="flex gap-2">
          <form phx-submit="appraise" class="flex flex-col gap-2">
            <h2 class="text-lg font-semibold py-2">Paste a list of items to appraise...</h2>
            <div>
              <.button>trade hub</.button>
              <.button>region</.button>
            </div>
            <.input type={"textarea"} name="appraisal" value="" class="p-4 rounded h-[50vh] min-w-[500px] ring-2 ring-black resize-none"/>
            <.button >Appraise</.button>
          </form>
          <div class="flex flex-col gap-2">
              <h2>Results</h2>
              <div class="flex flex-col">
              <%= Enum.map(@types, fn t ->  %>
                <div class="flex">
                <%= if elem(t, 2) == nil do %>
                  <span> <%= elem(t, 0) %></span>
                  <span> <%= elem(t, 1) %></span>
                  <span> unknown item </span>
                <% else %>
                  <span> <%= elem(t, 0) %></span>
                  <span> <%= elem(t, 1) %></span>
                  <span> <%= elem(t, 2).name %></span>
                <% end %>
                </div>
              <% end) %>
              </div>
          </div>
        </div>

      </section>
    """
  end

  def handle_event("appraise", %{"appraisal" => list_of_items}, socket) do
    items = AppraisalParser.parse(list_of_items)
    types = Enum.map(items, fn {t, a} -> {t, a, Types.get_type_by_name(t)} end)

    {:noreply, socket |> assign(:types, types)}
  end
end
