defmodule EveIndustrex.Infrastructure.ESI.UserAgent do
  @moduledoc false

  def value() do
    app =
      Application.spec(:eve_industrex, :vsn) |> to_string()

    contact = Application.fetch_env!(:eve_industrex, :esi_contact_email)

    "EveIndustrex/#{app} (contact: #{contact})"
  end
end
