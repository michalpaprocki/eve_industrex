defmodule EveIndustrexWeb.Api.Auth.CallbackController do
  use EveIndustrexWeb, :controller

  @moduledoc """
    Auth callback controller for EVE SSO.
  """

  def callback(conn, _params) do
    conn
    |> put_status(:not_implemented)
    |> text("Authentication is not implemented.")
  end
end
