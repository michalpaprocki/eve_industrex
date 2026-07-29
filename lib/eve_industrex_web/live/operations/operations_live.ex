defmodule EveIndustrexWeb.OperationsLive do
alias EveIndustrex.Infrastructure.Operations.Snapshot
alias EveIndustrex.ReleaseInfo
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Infrastructure.Operations
  def mount(_params, _session, socket) do
    %Snapshot{} = snapshot = Operations.Service.snapshot()
    {total_ms, _last_call_ms} = :erlang.statistics(:wall_clock)
    total_seconds = div(total_ms, 1000)
    up_time = seconds_to_date(total_seconds)
    if connected?(socket) do
      Process.send_after(self(), :refresh, 10000)
      Process.send_after(self(), :clock, 1000)
    end


    {:ok, socket |> assign(:snapshot, snapshot) |> assign(:up_time, up_time)}
  end
        # <span class={"w-4 h-4 bg-ei-success shadow-sm shadow-ei-success rounded-full mr-2"} />
  def render(assigns) do
    ~H"""
      <div class="flex flex-col gap-2 glass py-10">
        <h1 class="text-5xl text-center mb-10 font-headers">Operations</h1>
          <div class="flex flex-col gap-2 p-8 border-b-2 border-ie-text border-dotted">
            <div>
              <span> Application: </span>
              <span><%= ReleaseInfo.get().name %> </span>
            </div>
            <div>
              <span>Uptime: </span>
              <span><%= @up_time %></span>
            </div>
            <div>
              <span>Build: </span>
              <span><%= ReleaseInfo.get().version %></span>
            </div>
            <div>
              <span>OTP: </span>
              <span><%= ReleaseInfo.get().otp_release %></span>
            </div>
            <div>
              <span>Elixir: </span>
              <span><%= ReleaseInfo.get().elixir_version %></span>
            </div>
          </div>
          <div class="flex flex-col gap-2 p-8 border-b-2 border-ie-text border-dotted">
            <span class="text-center my-5 font-headers text-2xl">Resources: </span>
            <%= for r <- @snapshot.resources do %>
            <div class="flex flex-col gap-1 p-1 text-sm">
            <span><%= r.resource %></span>
              <div class="flex">

                <span>Projected: <%= DateTime.to_date(r.timestamp) %> : <%= Calendar.strftime(r.timestamp, "%H:%M") %></span>
              </div>
            </div>
            <% end %>

          </div>
          <div class="flex flex-col gap-2 p-8 border-b-2 border-ie-text border-dotted">
            <span class="text-center my-5 font-headers text-2xl">Sync Metrics: </span>

              <div class="flex flex-col gap-3 p-1 text-sm">

                <span class="text-base">Generations:</span>
                <div class="flex flex-col gap-1 p-1">

                  <div class="flex w-72 justify-between">
                     <span>Running: </span>
                     <span> <%= @snapshot.metrics.generations_running %> </span>
                  </div>
                  <div class="flex w-72 justify-between">
                     <span>Started: </span>
                     <span> <%= @snapshot.metrics.generations_started %> </span>
                  </div>
                  <div class="flex w-72 justify-between">
                     <span>Completed: </span>
                     <span class="text-end"> <%= @snapshot.metrics.generations_completed %> </span>
                  </div>
                  <div class="flex w-72 justify-between">
                     <span>Not Modified: </span>
                     <span> <%= @snapshot.metrics.generations_not_modified %> </span>
                  </div>
                  <div class="flex w-72 justify-between">
                     <span>Superseded: </span>
                     <span> <%= @snapshot.metrics.generations_superseded %> </span>
                  </div>
                  <div class="flex w-72 justify-between">
                     <span>Failed: </span>
                     <span> <%= @snapshot.metrics.generations_failed %> </span>
                  </div>
                  <div class="flex w-72 justify-between">
                     <span>Critical: </span>
                     <span> <%= @snapshot.metrics.generations_critical %> </span>
                  </div>
                </div>
                <span class="text-base">Pages:</span>
                <div class="flex flex-col gap-1 p-1">
                    <div class="flex w-72 justify-between">
                      <span>Completed:</span>
                      <span> <%= @snapshot.metrics.pages_completed %> </span>
                    </div>
                    <div class="flex w-72 justify-between">
                      <span>Rate Limited:</span>
                      <span> <%= @snapshot.metrics.pages_rate_limited %> </span>
                    </div>
                    <div class="flex w-72 justify-between">
                      <span>Retried:</span>
                      <span> <%= @snapshot.metrics.pages_retried %> </span>
                    </div>
                </div>
                <span class="text-base">Dependencies:</span>
                <div class="flex flex-col gap-1 p-1">
                    <div class="flex w-72 justify-between">
                      <span>Types Discovered:</span>
                      <span> <%= @snapshot.metrics.types_imported %> </span>
                    </div>
                    <div class="flex w-72 justify-between">
                      <span>Groups Discovered:</span>
                      <span> <%= @snapshot.metrics.groups_imported %> </span>
                    </div>
                    <div class="flex w-72 justify-between">
                      <span>Categories Discovered:</span>
                      <span> <%= @snapshot.metrics.categories_imported %> </span>
                    </div>
                    <div class="flex w-72 justify-between">
                      <span>Market Groups Discovered:</span>
                      <span> <%= @snapshot.metrics.market_groups_imported %> </span>
                    </div>
                </div>
                <div class="flex w-72 justify-between">
                  <span>Average Latency:</span>
                  <span><%= if @snapshot.metrics.duration_total_ms == 0, do: "N/A", else: floor(@snapshot.metrics.duration_total_ms / @snapshot.metrics.duration_count) %> ms</span>
                </div>

              </div>
          </div>
          <div class="flex flex-col gap-2 p-8 border-b-2 border-ie-text border-dotted">
            <span class="text-center my-5 font-headers text-2xl">Activity: </span>
            <div class="shard overflow-y-auto h-80 p-2">
            <%= for a <- @snapshot.activity do %>
              <div class="flex flex-col gap-1 p-1">
                <div class="flex flex-col w-72 justify-between text-sm gap-1 ">
                    <span><%= a.activity %></span>
                    <span> <%= DateTime.to_date(a.timestamp) %> : <%= DateTime.to_time(a.timestamp) %> </span>
                    <span><%= a.resource %> </span>
                    <span> <%= a.group %> </span>
                    <%= if a.count do %>
                    <span>Amount:  <%= a.count %> </span>
                    <% end %>
                </div>
              </div>

              <% end %>
            </div>

          </div>

          <%= if @snapshot.buckets != [] do %>
            <div class="flex flex-col gap-2 p-8">
              <span class="text-center my-5 font-headers text-2xl">ESI Rate Limiters: </span>
              <%= for {name, b} <- @snapshot.buckets do %>
                <div class="flex flex-col gap-1 p-1 text-sm">
                <span><%= name %></span>
                  <div class="flex items-center gap-2">
                  <%= if name == "global" do %>
                  <span>Remaining errors: <%= b.error_limit_remain %></span>
                  <% else %>

                    <span class={"rounded-full h-4 w-4 shadow-sm #{calc_rates_color(b.limit.capacity, b.remaining)}"} />
                    <span>Capacity: </span>
                    <span> <%= b.limit.capacity %> </span>
                    <span> Used:  </span>
                    <span> <%= calc_rate_percentage(b.limit.capacity, b.remaining) %> %</span>

                  <% end %>
                  </div>
                </div>
                <% end %>

            </div>
          <% end %>
        </div>
    """
  end
  def handle_info(:clock, socket) do
    {total_ms, _last_call} = :erlang.statistics(:wall_clock)
    total_seconds = div(total_ms, 1000)
    Process.send_after(self(), :clock, 1000)
    {:noreply, socket |> assign(:up_time, seconds_to_date(total_seconds))}
  end
  def handle_info(:refresh, socket) do
    Process.send_after(self(), :refresh, 10000)
    {:noreply, socket|>assign(:snapshot, Operations.Service.snapshot())}
  end
  defp calc_rates_color(cap, rem) do
    percentage = calc_rate_percentage(cap, rem)

    cond do
      percentage >= 70 ->
        "bg-ei-success shadow-ei-success"
      percentage >= 50 ->
        "bg-ei-warning shadow-ei-warning"
      percentage > 30 ->
        "bg-ei-warn shadow-ei-warn"

      true ->
        "bg-ei-critical shadow-ei-critical"

    end
  end
  defp seconds_to_date(total_seconds) do
    days = div(total_seconds, 86400)
    hours = div(rem(total_seconds, 86400), 3600)
    minutes = div(rem(total_seconds, 3600), 60)
    seconds = rem(total_seconds, 60)


      :io_lib.format("~Bd ~2..0B:~2..0B:~2..0B", [days, hours, minutes, seconds])
      |> List.to_string()
  end
  defp calc_rate_percentage(cap, rem) do
    rem / cap * 100 |> Float.floor(1)
  end

end
