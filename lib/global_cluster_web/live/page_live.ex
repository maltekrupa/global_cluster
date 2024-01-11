defmodule GlobalClusterWeb.PageLive do
  use GlobalClusterWeb, :live_view
  use Phoenix.Component

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
      send(self(), :add)
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
    <.mnesia_cluster mnesia_nodes={@mnesia_nodes} libcluster_nodes={@libcluster_nodes} all_nodes={@all_nodes} />
    <.table_rows rows={@table_rows} />
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
          <li>is an <a href="https://aws.amazon.com/ec2/instance-types/t3/">AWS t3.nano</a> instance</li>
          <li>is running <a href="https://www.freebsd.org/de/">FreeBSD 14</a> as operating system</li>
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
      The hardest part about this tech demo? Glueing the infrastructure together.
    </div>
    """
  end

  attr(:mnesia_nodes, :list, required: true)
  attr(:libcluster_nodes, :list, required: true)
  attr(:all_nodes, :list, required: true)

  def mnesia_cluster(assigns) do
    ~H"""
    <h3>Nodes</h3>
    <.table id="nodes" rows={@all_nodes}>
      <:col :let={node} label="Node"><%= node |> String.split("@") |> List.last %></:col>
      <:col :let={node} label="libcluster"><%= if node in @libcluster_nodes, do: "connected", else: "disconnected" %></:col>
      <:col :let={node} label="mnesia"><%= if node in @mnesia_nodes, do: "connected", else: "disconnected" %></:col>
    </.table>
    """
  end

  attr(:rows, :list, required: true)

  def table_rows(assigns) do
    ~H"""
    <h3>Mnesia table content</h3>
    <div>
      <.button phx-click="clear">Clear table</.button>
    </div>
    <br />
    <.table id="rows" rows={@rows}>
      <:col :let={row} label="Where"><%= elem(row, 1) %></:col>
      <:col :let={row} label="Visitor count"><%= elem(row, 2) %></:col>
    </.table>
    """
  end

  defp put_libcluster_nodes(socket) do
    libcluster_nodes =
      [Node.self() | Node.list()]
      |> Enum.map(&Atom.to_string/1)
      |> Enum.sort()

    socket
    |> assign(libcluster_nodes: libcluster_nodes)
  end

  defp put_all_nodes(socket) do
    topology = Application.get_env(:libcluster, :topologies)

    all_nodes =
      topology[:epmd][:config][:hosts]
      |> Enum.map(&Atom.to_string/1)

    socket
    |> assign(all_nodes: all_nodes)
  end

  defp put_mnesia_nodes(socket) do
    mnesia_nodes =
      Mnesiac.cluster_status()
      |> List.keyfind(:running_nodes, 0)
      |> elem(1)
      |> Enum.map(&Atom.to_string/1)
      |> Enum.sort()

    socket
    |> assign(mnesia_nodes: mnesia_nodes)
  end

  defp put_table_rows(socket) do
    rows =
      :ets.tab2list(:visitor)
      |> Enum.sort(:desc)

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

  defp add_visitor do
    node_name =
      Node.self()
      |> Atom.to_string()
      |> String.split("@")
      |> List.last()

    current_counter =
      case :mnesia.transaction(fn -> :mnesia.read({:visitor, node_name}) end) do
        {:atomic, []} -> 0
        {:atomic, x} -> x |> List.first() |> elem(2)
      end

    :mnesia.transaction(fn ->
      :mnesia.write({
        :visitor,
        node_name,
        current_counter + 1
      })
    end)
  end

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
  def handle_info(:add, socket) do
    add_visitor()
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _, socket) do
    :mnesia.clear_table(:visitor)

    {:noreply, socket}
  end
end
