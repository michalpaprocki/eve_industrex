defmodule EveIndustrex.Repo do
  use Ecto.Repo,
    otp_app: :eve_industrex,
    adapter: Ecto.Adapters.Postgres
end
