defmodule EveIndustrexWeb.HomeLive do
import EveIndustrexWeb.Glyph
  use EveIndustrexWeb, :live_view
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <section class="">
      <div class="flex flex-col gap-5 my-10">
        <h1 class="font-headers text-3xl">EveIndustr<span class="pl-[0.1rem] spacing-6 trailing-text">[EX]</span></h1>

        <h2 class="font-headers text-2xl">Industry and logistics tooling for EVE Online.</h2>
      </div>
        <div class="p-5">
            <ul class="flex flex-col gap-1">
            <li class="flex gap-5"><.glyph name="check"/> LP Profitability</li>
            <li class="flex gap-5"><.glyph name="check"/> Reaction Calculator</li>
            </ul>
        </div>
        <p class="mt-10">Currently in active development.</p>
      </section>
    """
  end
end
