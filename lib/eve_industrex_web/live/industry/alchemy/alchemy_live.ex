defmodule EveIndustrexWeb.AlchemyLive do

  use EveIndustrexWeb, :live_view


  @types ["SELL", "BUY"]

  def mount(_params, _session, socket) do
    recipes = Bluepr
    {:ok, socket
  }
  end

  def render(assigns) do
    ~H"""
    <section>
      <h1 class="text-xl font-bold py-10">Alchemy </h1>

    </section>
    """
  end



end
