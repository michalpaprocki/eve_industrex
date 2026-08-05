defmodule EveIndustrexWeb.Api.NotFoundController do
  use EveIndustrexWeb, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> text("Not found")
  end
end
