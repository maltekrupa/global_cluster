# Clust

Global mnesia test cluster.

# Start node

If you only need one node, start it via:

```
mix phx.server
```

If you need multiple nodes, start each of them in a terminal:

```
iex --name a@127.0.0.1 -S mix phx.server
```

```
iex --name b@127.0.0.1 -S mix
```

Afterwards libcluster should take care of forming a cluster and mnesiac should
form a mnesia cluster.
