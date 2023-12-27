defmodule GlobalCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topology = Application.get_env(:libcluster, :topologies)
    hosts = topology[:epmd_example][:config][:hosts]

    children = [
      {Cluster.Supervisor, [topology, [name: GlobalCluster.ClusterSupervisor]]},
      {Mnesiac.Supervisor, [hosts, [name: GlobalCluster.MnesiacSupervisor]]},
      GlobalClusterWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:global_cluster, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GlobalCluster.PubSub},
      # Start a worker by calling: GlobalCluster.Worker.start_link(arg)
      # {GlobalCluster.Worker, arg},
      # Start to serve requests, typically the last entry
      GlobalClusterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GlobalCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GlobalClusterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
