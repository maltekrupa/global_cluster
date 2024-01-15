defmodule GlobalClusterWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :global_cluster

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_global_cluster_key",
    signing_salt: "tD8hukIK",
    same_site: "Lax"
  ]

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :global_cluster,
    gzip: false,
    only: GlobalClusterWeb.static_paths()
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(:counter)
  plug(GlobalClusterWeb.Router)

  def counter(conn, _opts) do
    current_counter =
      case :mnesia.transaction(fn -> :mnesia.read({:visitor, Node.self()}) end) do
        {:atomic, []} -> 0
        {:atomic, x} -> x |> List.first() |> elem(2)
      end

    :mnesia.transaction(fn ->
      :mnesia.write({
        :visitor,
        Node.self(),
        current_counter + 1
      })
    end)

    conn
  end
end
