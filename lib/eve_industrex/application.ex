defmodule EveIndustrex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EveIndustrexWeb.Telemetry,
      EveIndustrex.Repo,
      {DNSCluster, query: Application.get_env(:eve_industrex, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EveIndustrex.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: EveIndustrex.Finch},
      # Start a worker by calling: EveIndustrex.Worker.start_link(arg)
      # {EveIndustrex.Worker, arg},
      # Start to serve requests, typically the last entry
      EveIndustrexWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EveIndustrex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EveIndustrexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
