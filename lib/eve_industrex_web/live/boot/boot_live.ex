defmodule EveIndustrexWeb.BootLive do
  alias EveIndustrex.Infrastructure.Readiness
  alias EveIndustrexWeb.Endpoint
  use EveIndustrexWeb, :live_view

  def mount(_params, _session, socket) do
    state = Readiness.read_state()

    state_map =
      Map.new(state, fn {k, v} ->
        {k, v}
      end)

    ready =
      Enum.all?(state, fn {_k, v} ->
        v == true
      end)

    Endpoint.subscribe("readiness")
    socket = assign(socket, state_map)
    {:ok, socket |> assign(:ready, ready)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <h1 class="text-5xl font-headers text-center my-10">
        EveIndustr<span class="trailing-text">EX</span>
      </h1>
      <%= if @ready do %>
        <h2 class="text-2xl text-center font-headers mb-15">bootstraped successfully</h2>
      <% else %>
        <h2 class="text-2xl text-center font-headers mb-15">is bootstraping...</h2>
      <% end %>
      <div class="glass flex flex-col text-sm p-10">
        <div class="flex gap-4 p-2">
          <%= if @bootstrap do %>
            <span class=""><.glyph name="check" /></span>
            <span>Static Universe Loaded</span>
          <% else %>
            <span class="animate-spin "><.glyph name="loader" /></span>
            <span>Static Universe Loading...</span>
          <% end %>
        </div>
        <div class="flex gap-4 p-2">
          <%= if @sde_cache do %>
            <span class=""><.glyph name="check" /></span>
            <span>SDE Cache Loaded</span>
          <% else %>
            <span class="animate-spin "><.glyph name="loader" /></span>
            <span>SDE Cache Loading...</span>
          <% end %>
        </div>
        <div class="flex gap-4 p-2">
          <%= if @system_cost_index do %>
            <span class=""><.glyph name="check" /></span>
            <span>System Cost Index Projection Built </span>
          <% else %>
            <span class="animate-spin "><.glyph name="loader" /></span>
            <span>Building System Cost Index Projection...</span>
          <% end %>
        </div>
        <div class="flex gap-4 p-2">
          <%= if @average_prices do %>
            <span class=""><.glyph name="check" /></span>
            <span>Average Prices Projection Built </span>
          <% else %>
            <span class="animate-spin "><.glyph name="loader" /></span>
            <span>Building Average Prices Projection...</span>
          <% end %>
        </div>
        <div class="flex gap-4 p-2">
          <%= if @market_orders do %>
            <span class=""><.glyph name="check" /></span>
            <span>Market Orders Projection Built </span>
          <% else %>
            <span class="animate-spin "><.glyph name="loader" /></span>
            <span>Building Market Orders Projection...</span>
          <% end %>
        </div>
        <div class="p-2 mt-20 text-center text-lg">
          <%= if @ready do %>
            Done
          <% else %>
            Please Wait...
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(%{topic: "readiness", event: "ready", payload: flag} = _msg, socket) do
    Process.send_after(self(), :check, 1000)

    case flag do
      "bootstrap" ->
        {:noreply, socket |> assign(:bootstrap, true)}

      "sde_cache" ->
        {:noreply, socket |> assign(:sde_cache, true)}

      "market_orders" ->
        {:noreply, socket |> assign(:market_orders, true)}

      "average_prices" ->
        {:noreply, socket |> assign(:average_prices, true)}

      "system_cost_index" ->
        {:noreply, socket |> assign(:system_cost_index, true)}
    end
  end

  def handle_info(:check, socket) do
    if Enum.all?(socket.assigns, fn a -> a == true end) do
      {:noreply, socket |> put_flash(:info, "Bootstraping Completed...") |> redirect(to: ~p"/")}
    else
      {:noreply, socket}
    end
  end
end
