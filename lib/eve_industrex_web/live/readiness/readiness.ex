defmodule EveIndustrexWeb.Readiness do
  use EveIndustrexWeb, :live_view
  alias EveIndustrex.Infrastructure.Readiness
  @moduledoc false
  def on_mount(:default, _params, _session, socket) do
    if Readiness.ready?() do
      {:cont, socket}
    else
      {:halt,
       socket |> put_flash(:info, "EveIndustrex is bootstraping...") |> redirect(to: ~p"/boot")}
    end
  end
end
