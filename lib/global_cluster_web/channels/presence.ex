defmodule GlobalClusterWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :global_cluster,
    pubsub_server: GlobalCluster.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def count_online_users(node) do
    node =
      node
      |> Atom.to_string()

    list("online_users")
    |> Enum.reduce(%{}, fn {^node, presence}, acc ->
      Map.put(
        acc,
        node |> String.to_atom(),
        length(presence.metas)
      )
    end)
  end

  def track_user(name, params) do
    track(self(), "online_users", name, params)
  end

  def subscribe, do: Phoenix.PubSub.subscribe(GlobalCluster.PubSub, "online_users")
end
