defmodule Clust do
  @moduledoc """
  Documentation for `ClusterTest`.
  """

  use Application

  def start(_type, _args) do
    topology = Application.get_env(:libcluster, :topologies)
    hosts = topology[:epmd_example][:config][:hosts]

    children = [
      {Cluster.Supervisor, [topology, [name: Clust.ClusterSupervisor]]},
      {Mnesiac.Supervisor, [hosts, [name: Clust.MnesiacSupervisor]]}
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: Clust.Supervisor)
  end
end
