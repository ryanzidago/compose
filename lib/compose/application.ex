defmodule Compose.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ComposeWeb.Telemetry,
      Compose.Repo,
      {DNSCluster, query: Application.get_env(:compose, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Compose.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Compose.Finch},
      # Start a worker by calling: Compose.Worker.start_link(arg)
      # {Compose.Worker, arg},
      # Start to serve requests, typically the last entry
      ComposeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Compose.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ComposeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
