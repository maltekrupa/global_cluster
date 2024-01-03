defmodule GlobalClusterWeb.PageLive do
  use GlobalClusterWeb, :live_view
  use Phoenix.Component

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, put_mnesia_nodes(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>PageLive loaded!</div>
      <.mnesia_nodes mnesia_nodes={@mnesia_nodes} all_nodes={@all_nodes} />
    """
  end

  attr(:mnesia_nodes, :list, required: true)
  attr(:all_nodes, :list, required: true)

  def mnesia_nodes(assigns) do
    ~H"""
      <h3>Cluster nodes</h3>
      <.table id="nodes" rows={@all_nodes}>
        <:col :let={node} label="Node"><%= node %></:col>
        <:col :let={node} label="Part of cluster"><%= node in @mnesia_nodes %></:col>
      </.table>
    """
  end

  defp put_mnesia_nodes(socket) do
    topology = Application.get_env(:libcluster, :topologies)

    all_nodes =
      topology[:epmd_example][:config][:hosts]
      |> Enum.map(&Atom.to_string/1)

    mnesia_nodes =
      Mnesiac.cluster_status()
      |> List.keyfind(:running_nodes, 0)
      |> elem(1)
      |> Enum.map(&Atom.to_string/1)
      |> Enum.sort()

    socket
    |> assign(mnesia_nodes: mnesia_nodes)
    |> assign(all_nodes: all_nodes)
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, put_mnesia_nodes(socket)}
  end
end
