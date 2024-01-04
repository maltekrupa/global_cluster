defmodule GlobalClusterWeb.PageLive do
  use GlobalClusterWeb, :live_view
  use Phoenix.Component

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok,
     socket
     |> assign(:page_title, "Global Cluster")
     |> put_mnesia_nodes()
     |> put_table_rows()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.intro />
    <.mnesia_cluster mnesia_nodes={@mnesia_nodes} all_nodes={@all_nodes} />
    <.table_rows rows={@table_rows} />
    """
  end

  def intro(assigns) do
    ~H"""
    <div>
      This is an example application running on four t3.nano instances. Each instance is running on a different continent.
    </div>
    <div>
      All VMs are using FreeBSD and are connected to each other using a wireguard mesh.
    </div>
    <div>
      The application itself is built using the phoenix framework.
    </div>
    """
  end

  attr(:mnesia_nodes, :list, required: true)
  attr(:all_nodes, :list, required: true)

  def mnesia_cluster(assigns) do
    ~H"""
    <h3>Nodes</h3>
    <.table id="nodes" rows={@all_nodes}>
      <:col :let={node} label="Node"><%= node |> String.split("@") |> List.last %></:col>
      <:col :let={node} label="Part of mnesia"><%= node in @mnesia_nodes %></:col>
    </.table>
    """
  end

  attr(:rows, :list, required: true)

  def table_rows(assigns) do
    ~H"""
    <h3>Mnesia table content</h3>
    <.table id="rows" rows={@rows}>
      <:col :let={row} label="ID"><%= elem(row, 1) %></:col>
      <:col :let={row} label="Topic"><%= elem(row, 2) %></:col>
      <:col :let={row} label="Event"><%= elem(row, 3) %></:col>
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

  defp put_table_rows(socket) do
    rows = :ets.tab2list(:example)

    socket
    |> assign(table_rows: rows)
  end

  defp put_os_version(socket) do
    {os, 0} = System.cmd("uname", ["-o"])
    {os_version, 0} = System.cmd("uname", ["-r"])

    socket
    |> assign(os: os)
    |> assign(os_version: os_version)
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> put_mnesia_nodes()
     |> put_table_rows()}
  end
end
