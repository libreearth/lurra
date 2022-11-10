defmodule Lurra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Lurra.Repo,
      # Start the Telemetry supervisor
      LurraWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Lurra.PubSub},
      # Start the Endpoint (http/https)
      LurraWeb.Endpoint,
      # Start a worker by calling: Lurra.Worker.start_link(arg)
      # {Lurra.Worker, arg}
      Lurra.ObserverConnectors.Twc,
      Lurra.ObserverConnectors.Wolkietolkie,
      Lurra.ObserverConnectors.Mqtt,
      Lurra.Events.ReadingsCache,
      Lurra.Triggers.Server,
      {Registry, keys: :unique, name: Registry.EcoOasis},
      Lurra.Core.EcoOasis.Server.ServerSupervisor,
      {Task, &Lurra.Core.EcoOasis.Server.ServerSupervisor.initial_eco_oasis/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lurra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LurraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
