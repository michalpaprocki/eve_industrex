defmodule EveIndustrexWeb.Dashboard.DashboardLive do
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Infrastructure.ESI.Sync.Query
  alias EveIndustrex.Infrastructure.ESI.RateLimiter
  @options [1, 5, 10, 20]
  @form_types %{step: :integer}
  def mount(_params, _session, socket) do
    sync_runtime =
      :ets.tab2list(:sync_runtime)
      |> Enum.sort(&(elem(&1, 1).started_at > elem(&2, 1).started_at))

    sync_events =
      :ets.tab2list(:sync_events) |> Enum.sort(&(elem(&1, 1).timestamp > elem(&2, 1).timestamp))

    sync_metrics = :ets.tab2list(:sync_metrics) |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    resource_types = Query.get_resource_types()
    rate_limit = RateLimiter.check()

    strategies_count =
      Enum.map(resource_types, fn r ->
        %{name: r.name, count: Query.get_resource_strategies_count(r.name).count}
      end)

    params = %{"step" => 10}

    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    Process.send_after(self(), {:tick}, 1000)
    Process.send_after(self(), {:metrics}, 10_000)

    {:ok,
     socket
     |> assign(:metrics, sync_metrics)
     |> assign(:events, sync_events)
     |> assign(:runtime, sync_runtime)
     |> assign(:show_details, false)
     |> assign(:strategies, strategies_count)
     |> assign(:show_runtime, false)
     |> assign(:show_events, false)
     |> assign(:rate_limit, rate_limit)
     |> assign(:options, @options)
     |> assign(:time, DateTime.utc_now() |> DateTime.truncate(:second))
     |> assign(:form, to_form(changeset, as: :form))}
  end

  def render(assigns) do
    ~H"""
    <section class="flex flex-col">
      <h1 class="text-2xl text-center py-10 text-white">Sync Telemetry</h1>
      <span class="self-center text-white p-2 font-semibold text-xl">
        {DateTime.to_date(@time)} {DateTime.to_time(@time)}
      </span>
      <div class="flex flex-col gap-2">
        <div class="flex flex-col">
          <div class="p-1 flex flex-col bg-black/70 text-white rounded-md gap-2">
            <h2 class="text-center font-semibold text-xl">Strategies</h2>
            <%= for s <- @strategies do %>
              <div class="flex flex-col p-1">
                <span class="">Name: {s.name}</span>
                <span class="">Count: {s.count}</span>
              </div>
            <% end %>
          </div>
        </div>
        <div class="p-1 flex flex-col bg-black/70 text-white rounded-md gap-2">
          <h2 class="text-center font-semibold text-xl">Rate Limits</h2>
          <%= for {route_group, bucket} <- @rate_limit do %>
            <%= if route_group == "global" do %>
              <div class="flex flex-col p-1">
                <span class="">Route: {route_group}</span>
                <span class="">Resets in: {bucket.error_limit_reset}</span>
                <span class="">Errors Remaining: {bucket.error_limit_remain}</span>
                <span class="">
                  Updated at: {DateTime.to_date(bucket.updated_at)} {DateTime.to_time(
                    bucket.updated_at
                  )}
                </span>
              </div>
            <% else %>
              <div class="flex flex-col p-1">
                <span class="">Route: {route_group}</span>
                <span class="">Capacity: {bucket.limit.capacity}</span>
                <span class="">Remaining: {bucket.remaining}</span>
                <span class="">
                  Updated at: {DateTime.to_date(bucket.updated_at)} {DateTime.to_time(
                    bucket.updated_at
                  )}
                </span>
              </div>
            <% end %>
          <% end %>
        </div>

        <div class="p-2 ring-1 ring-black rounded-md text-white bg-black/70">
          <h2 class="text-xl py-5 text-center">Metrics</h2>
          <.form for={@form} id="step_form" phx-change="validate_form">
            <.input
              field={@form[:step]}
              value={@form[:step].value}
              type="select"
              class="w-fit mb-4 text-black"
              label="Refresh rate"
              name="step"
              options={Enum.map(@options, fn x -> x end)}
              id="step_select"
            />
          </.form>
          <div class="flex flex-col gap-1">
            <%= for {k, v} <- @metrics do %>
              <span class="capitalize p-1 font-semibold">{k}: {v}</span>
            <% end %>
          </div>
        </div>

        <div class="p-2 ring-1 ring-black rounded-md flex flex-col">
          <h2 class="text-xl py-5 text-center">Runtime</h2>
          <.button class="w-[20ch] self-center" phx-click="toggle_runtime">
            {if @show_runtime, do: "hide runtime", else: "show runtime"}
          </.button>

          <%= if @show_runtime do %>
            <div class="flex flex-col gap-1">
              <%= for {k, v} <- @runtime do %>
                <div class="flex flex-col gap-1 py-2">
                  <span class="capitalize p-1 font-semibold">Strategy id: {k}</span>
                  <span class="capitalize p-1 font-semibold">Status: {v.status}</span>
                  <.live_component
                    module={EveIndustrexWeb.Dashboard.RuntimeDetails}
                    id={k}
                    details={v}
                  />
                </div>
              <% end %>
            </div>
          <% end %>
        </div>

        <div class="p-2 ring-1 ring-black rounded-md flex flex-col">
          <h2 class="text-xl py-5 text-center">Events</h2>
          <.button class="w-[20ch] mb-2 self-center" phx-click="toggle_events">
            {if @show_events, do: "hide events", else: "show events"}
          </.button>
          <%= if @show_events do %>
            <div class="flex flex-col gap-1">
              <%= for {_k, v} <- @events do %>
                <%= case v.event do %>
                  <% :generation_completed -> %>
                    <div class="flex flex-col gap-1 p-2 rounded-md bg-emerald-700 text-white">
                      <span class="">{v.event}</span>
                      <span>{DateTime.to_date(v.timestamp)} {DateTime.to_time(v.timestamp)}</span>
                      <span>{v.metadata.resource}</span>
                      <span>strategy id: {v.metadata.strategy_id}</span>
                    </div>
                  <% :generation_not_modified -> %>
                    <div class="flex flex-col gap-1 p-2 rounded-md bg-sky-700 text-white">
                      <span class="">{v.event}</span>
                      <span>{DateTime.to_date(v.timestamp)} {DateTime.to_time(v.timestamp)}</span>
                      <span>{v.metadata.resource}</span>
                      <span>strategy id: {v.metadata.strategy_id}</span>
                    </div>
                  <% :generation_critical -> %>
                    <div class="flex flex-col gap-1 p-2 rounded-md bg-red-700 text-white">
                      <span class="">{v.event}</span>
                      <span>{DateTime.to_date(v.timestamp)} {DateTime.to_time(v.timestamp)}</span>
                      <span>{v.metadata.resource}</span>
                      <span>strategy id: {v.metadata.strategy_id}</span>
                    </div>
                  <% :generation_failed -> %>
                    <div class="flex flex-col gap-1 p-2 rounded-md bg-orange-700 text-white">
                      <span class="">{v.event}</span>
                      <span>{DateTime.to_date(v.timestamp)} {DateTime.to_time(v.timestamp)}</span>
                      <span>{v.metadata.resource}</span>
                      <span>strategy id: {v.metadata.strategy_id}</span>
                    </div>
                  <% :generation_superseded -> %>
                    <div class="flex flex-col gap-1 p-2 rounded-md bg-teal-700 text-white">
                      <span class="">{v.event}</span>
                      <span>{DateTime.to_date(v.timestamp)} {DateTime.to_time(v.timestamp)}</span>
                      <span>{v.metadata.resource}</span>
                      <span>strategy id: {v.metadata.strategy_id}</span>
                    </div>
                  <% _ -> %>
                    <div class="flex flex-col gap-1 p-2 rounded-md">
                      <span class="">{v.event}</span>
                      <span>{DateTime.to_date(v.timestamp)} {DateTime.to_time(v.timestamp)}</span>
                      <span>{v.metadata.resource}</span>
                      <span>strategy id: {v.metadata.strategy_id}</span>
                    </div>
                <% end %>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  def handle_event("toggle_runtime", _unsigned_params, socket) do
    {:noreply, socket |> assign(:show_runtime, !socket.assigns.show_runtime)}
  end

  def handle_event("toggle_events", _unsigned_params, socket) do
    {:noreply, socket |> assign(:show_events, !socket.assigns.show_events)}
  end

  def handle_event("validate_form", params, socket) do
    changeset =
      {%{}, @form_types}
      |> Ecto.Changeset.cast(params, Map.keys(@form_types))

    {:noreply, socket |> assign(:form, to_form(changeset, as: :form))}
  end

  def handle_info({:tick}, socket) do
    Process.send_after(self(), {:tick}, 1000)
    {:noreply, socket |> assign(:time, DateTime.utc_now() |> DateTime.truncate(:second))}
  end

  def handle_info({:metrics}, socket) do
    Process.send_after(self(), {:metrics}, socket.assigns.form[:step].value * 1000)
    sync_metrics = :ets.tab2list(:sync_metrics) |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    rate_limit = RateLimiter.check()

    sync_events =
      :ets.tab2list(:sync_events) |> Enum.sort(&(elem(&1, 1).timestamp > elem(&2, 1).timestamp))

    {:noreply,
     socket
     |> assign(:metrics, sync_metrics)
     |> assign(:rate_limit, rate_limit)
     |> assign(:events, sync_events)}
  end
end
