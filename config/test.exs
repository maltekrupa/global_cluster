import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :global_cluster, GlobalClusterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "BhLukwdopS1rD0EEi2nG2F+qdlXVcfCoD8FuiA5LqOqkIQ3lDY1dmDnMw2tj4WBT",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :libcluster,
  topologies: [
    epmd: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Epmd,
      # Configuration for the provided strategy. Optional.
      config: [
        hosts: [
          :"a@127.0.0.1"
        ]
      ]
    ]
  ]
