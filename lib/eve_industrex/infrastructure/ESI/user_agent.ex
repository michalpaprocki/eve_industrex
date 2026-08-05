defmodule EveIndustrex.Infrastructure.ESI.UserAgent do
  @moduledoc false
  import Config, only: [config_env: 0]

  def value() do
    app =
      Application.spec(:eve_industrex, :vsn) |> to_string()

    env = config_env()
    contact = Application.fetch_env!(:eve_industrex, :esi_contact_email)

    "EveIndustrex/#{app} (#{env}; contact: #{contact})"
  end
end
