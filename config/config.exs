# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :global_cluster,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :global_cluster, GlobalClusterWeb.Endpoint,
  url: [host: "gc.nafn.de"],
  check_origin: [
    "http://gc.nafn.de",
    "http://eu-central-1.gc.nafn.de",
    "http://af-south-1.gc.nafn.de",
    "http://ap-northeast-1.gc.nafn.de",
    "http://sa-east-1.gc.nafn.de"
  ],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: GlobalClusterWeb.ErrorHTML, json: GlobalClusterWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GlobalCluster.PubSub,
  live_view: [signing_salt: "shmcSytl"]

config :mnesiac,
  stores: [GlobalCluster.VisitorStore],
  # TODO: This seems to be useless?
  dir: ~c".mnesia/#{node()}",
  # :ram_copies or :disc_copies
  schema_type: :ram_copies,
  # milliseconds, default is 600_000
  table_load_timeout: 600_000

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
