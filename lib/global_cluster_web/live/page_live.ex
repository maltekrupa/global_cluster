defmodule GlobalClusterWeb.PageLive do
  use GlobalClusterWeb, :live_view
  use Phoenix.Component

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok,
     socket
     |> assign(:page_title, "Global Cluster - Tech Demo")
     |> put_mnesia_nodes()
     |> put_libcluster_nodes()
     |> put_all_nodes()
     |> put_table_rows()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.intro />
    <.mnesia_cluster mnesia_nodes={@mnesia_nodes} libcluster_nodes={@libcluster_nodes} all_nodes={@all_nodes} table_rows={@table_rows} />
    """
  end

  def intro(assigns) do
    ~H"""
    <div>
      The facts about this tech demo:
      <ul>
        <li>four virtual machines (VM)</li>
        <li>each of them</li>
        <ul>
          <li>is running on a different continent</li>
          <li>is an <a href="https://aws.amazon.com/ec2/instance-types/t3/">AWS t3.nano</a> instance (2 vcpu, 5% baseline performance/vcpu, 512MB memory)</li>
          <li>is running <a href="https://www.freebsd.org/">FreeBSD 14</a> as operating system</li>
          <li>is connected to all other VMs using a <a href="https://www.wireguard.com/">wireguard</a> mesh</li>
        </ul>
        <li>all VMs run an Elixir application that</li>
        <ul>
          <li>is built using the <a href="https://www.phoenixframework.org/">Phoenix Framework</a></li>
          <li>creates a cluster over all involved VMs using <a href="https://github.com/bitwalker/libcluster">libcluster</a></li>
          <li>creates an in-memory <a href="https://en.wikipedia.org/wiki/Mnesia">mnesia database</a> using all nodes</li>
        </ul>
      </ul>
    </div>
    <div>
      <b>Note:</b> This demo does not use anycast or regional DNS to steer you a more local node.
    </div>
    <div>
      Involved nodes:
      <ul>
        <li><a href="http://eu-central-1.gc.nafn.de">Europe - Frankfurt</a></li>
        <li><a href="http://af-south-1.gc.nafn.de">Africa - Cape Town</a></li>
        <li><a href="http://ap-northeast-1.gc.nafn.de">Asia Pacific - Tokyo</a></li>
        <li><a href="http://sa-east-1.gc.nafn.de">South America - Sao Paulo</a></li>
      </ul>
    </div>
    """
  end

  attr(:mnesia_nodes, :list, required: true)
  attr(:libcluster_nodes, :list, required: true)
  attr(:all_nodes, :list, required: true)
  attr(:table_rows, :list, required: true)

  def mnesia_cluster(assigns) do
    ~H"""
    <h3>Nodes</h3>
    <.table id="nodes" rows={@all_nodes}>
      <:col :let={node} label="Node"><%= node |> Atom.to_string() |> String.split("@") |> List.last %></:col>
      <:col :let={node} label="libcluster"><%= if node in @libcluster_nodes, do: "connected", else: "disconnected" %></:col>
      <:col :let={node} label="mnesia"><%= if node in @mnesia_nodes, do: "connected", else: "disconnected" %></:col>
      <:col :let={node} label="visitors"><%= Map.get(@table_rows, node) %></:col>
    </.table>
    """
  end

  defp put_libcluster_nodes(socket) do
    libcluster_nodes = [Node.self() | Node.list()]

    socket
    |> assign(libcluster_nodes: libcluster_nodes)
  end

  defp put_all_nodes(socket) do
    topology = Application.get_env(:libcluster, :topologies)
    all_nodes = topology[:epmd][:config][:hosts]

    socket
    |> assign(all_nodes: all_nodes)
  end

  defp put_mnesia_nodes(socket) do
    mnesia_nodes =
      Mnesiac.cluster_status()
      |> List.keyfind(:running_nodes, 0)
      |> elem(1)

    socket
    |> assign(mnesia_nodes: mnesia_nodes)
  end

  defp put_table_rows(socket) do
    rows = :ets.tab2list(:visitor)

    rows =
      Enum.reduce(rows, %{}, fn {_, node, counter}, acc ->
        Map.put(acc, node, counter)
      end)

    socket
    |> assign(table_rows: rows)
  end

  # defp put_os_version(socket) do
  #   {os, 0} = System.cmd("uname", ["-o"])
  #   {os_version, 0} = System.cmd("uname", ["-r"])

  #   socket
  #   |> assign(os: os)
  #   |> assign(os_version: os_version)
  # end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> put_mnesia_nodes()
     |> put_libcluster_nodes()
     |> put_all_nodes()
     |> put_table_rows()}
  end

  @impl true
  def handle_event("clear", _, socket) do
    :mnesia.clear_table(:visitor)

    {:noreply, socket}
  end
end
