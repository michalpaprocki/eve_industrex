defmodule EveIndustrexWeb.NotFoundController do
  use EveIndustrexWeb, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render(:not_found, layout: false)
  end
end
