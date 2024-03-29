defmodule GlobalClusterWeb.PageLive do
  use GlobalClusterWeb, :live_view
  use Phoenix.Component

  embed_templates("templates/*")

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)

      GlobalClusterWeb.Presence.track_user(Node.self(), %{})
      GlobalClusterWeb.Presence.subscribe()
    end

    {:ok,
     socket
     |> assign(:page_title, "Global Cluster - Tech Demo")
     |> assign(user_count: GlobalClusterWeb.Presence.count_online_users())
     |> put_mnesia_nodes()
     |> put_libcluster_nodes()
     |> put_all_nodes()
     |> put_table_rows()
     |> put_http_links()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.welcome />
    <h3>Node table</h3>
    <.mnesia_cluster
      mnesia_nodes={@mnesia_nodes}
      libcluster_nodes={@libcluster_nodes}
      all_nodes={@all_nodes}
      table_rows={@table_rows}
      http_links={@http_links}
      user_count={@user_count}
    />
    <h3>Node map</h3>
    <.world_map libcluster_nodes={@libcluster_nodes} mnesia_nodes={@mnesia_nodes} />
    <h3>Why?</h3>
    <.why />
    <h3>Technical details</h3>
    <.details />
    """
  end

  def welcome(assigns) do
    ~H"""
    <div>
      <p>This is a globally distributed Elixir application with a shared in-memory mnesia database that provides a visitor counter.</p>
      <p>You can find the code on github: <a href="https://github.com/maltekrupa/global_cluster">maltekrupa/global_cluster</a>.</p>
    </div>
    """
  end

  def why(assigns) do
    ~H"""
    <div>
      <p>The BEAM (the runtime Elixir uses) is said to be very robust and I wanted to see how complicated it gets when you try to build a clustered application. The default scenario would've been to run multiple high-performance servers close to each other so you can make use of a low-latency high-bandwith network. I instead choose the path of using virtual servers with very limited resources connected over a long distance.</p>
      <p>Did it work? Yes. Was it hard to build? No. Is it fast? Not really. :)</p>
      <p>At the end it is a <b>technical demonstration</b>. Nothing more, nothing less. It does not provide anything useful other than an <b>opportunity to learn</b>. And of course a strange way to burn money.</p>
    </div>
    """
  end

  def details(assigns) do
    ~H"""
    <div>
      Some facts about the four virtual machines:
      <ul>
        <li>they're <a href="https://aws.amazon.com/ec2/instance-types/t3/">AWS t3.nano</a> instances (2 vcpu, 5% baseline performance/vcpu, 512MB memory)</li>
        <li>each of them runs on a different continent</li>
        <li>they use <a href="https://www.freebsd.org/">FreeBSD 14</a> as operating system</li>
        <li>they're interconnected using a <a href="https://www.wireguard.com/">wireguard</a> mesh</li>
      </ul>
      Some facts about the application:
      <ul>
        <li>it is built using the <a href="https://www.phoenixframework.org/">Phoenix Framework</a></li>
        <li>cluster creation is done using <a href="https://github.com/bitwalker/libcluster">libcluster</a></li>
        <li>the in-memory database is making use of <a href="https://en.wikipedia.org/wiki/Mnesia">mnesia</a></li>
      </ul>
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
    <div>
      <p><b>Note:</b> This demonstration does not use anycast or regional DNS to steer you a more local node. <a href="http://gc.nafn.de">gc.nafn.de</a> is a CNAME to eu-central-1.</p>
    </div>
    """
  end

  attr(:mnesia_nodes, :list, required: true)
  attr(:libcluster_nodes, :list, required: true)
  attr(:all_nodes, :list, required: true)
  attr(:table_rows, :map, required: true)
  attr(:http_links, :map, required: true)
  attr(:user_count, :map, required: true)

  def mnesia_cluster(assigns) do
    ~H"""
    <.table id="nodes" rows={@all_nodes}>
      <:col :let={node} label="Node"><%= raw(Map.get(@http_links, node)) %></:col>
      <:col :let={node} label="libcluster"><%= if node in @libcluster_nodes, do: "connected", else: "disconnected" %></:col>
      <:col :let={node} label="mnesia"><%= if node in @mnesia_nodes, do: "connected", else: "disconnected" %></:col>
      <:col :let={node} label="Visitors"><%= Map.get(@table_rows, node) %></:col>
      <:col :let={node} label="Active Users"><%= Map.get(@user_count, node, 0) %></:col>
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

  defp put_http_links(socket) do
    domain = "gc.nafn.de"

    http_links =
      Enum.reduce(socket.assigns.all_nodes, %{}, fn node, acc ->
        normalized = node |> Atom.to_string() |> String.split("@") |> List.last()
        Map.put(acc, node, "<a href=\"http://#{normalized}.#{domain}\">#{normalized}</a>")
      end)

    socket
    |> assign(http_links: http_links)
  end

  defp svg_point_color(node, mnesia_nodes, libcluster_nodes) do
    cond do
      node in mnesia_nodes and node in libcluster_nodes -> "#28fc03"
      node in libcluster_nodes -> "#0800ff"
      true -> "red"
    end
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
     |> put_table_rows()
     |> put_http_links()}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    user_count = GlobalClusterWeb.Presence.count_online_users()

    {:noreply, assign(socket, user_count: user_count)}
  end
end
