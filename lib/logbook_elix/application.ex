defmodule LogbookElix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LogbookElixWeb.Telemetry,
      LogbookElix.Repo,
      {DNSCluster, query: Application.get_env(:logbook_elix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LogbookElix.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LogbookElix.Finch},
      # Start Cachex for Google certificates caching
      {Cachex, name: :google_certs_cache},
      # Start a worker by calling: LogbookElix.Worker.start_link(arg)
      # {LogbookElix.Worker, arg},
      # Start to serve requests, typically the last entry
      LogbookElixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LogbookElix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LogbookElixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
