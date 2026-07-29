defmodule EveIndustrex.Release do
  defstruct [:name, :version, :otp_release, :elixir_version]

  def get() do
    struct(__MODULE__,
    name: Application.spec(:eve_industrex, :description) |> List.to_string(),
    version: Application.spec(:eve_industrex, :vsn) |> List.to_string(),
    otp_release: System.otp_release(),
    elixir_version: System.version()
    )
  end
end
