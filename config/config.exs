import Config

config :mnesiac,
  stores: [Clust.ExampleStore],
  dir: '.mnesia/#{node()}',
  schema_type: :disc_copies, # or :disc_copies
  table_load_timeout: 600_000 # milliseconds, default is 600_000

config :libcluster,
  topologies: [
    epmd_example: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Epmd,
      # Configuration for the provided strategy. Optional.
      config: [hosts: [:"a@127.0.0.1", :"b@127.0.0.1"]]
    ]
  ]
