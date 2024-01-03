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

# Commands to test mnesia

## Information gathering

```
:mnesia.info
```

```
Mnesiac.cluster_status
```

## Dirty Write

```
:mnesia.dirty_write({:example, 1, 1, 1})
:mnesia.dirty_write({:example, 2, 2, 2})
:mnesia.dirty_write({:example, 3, 4, 5})
```

## Write

```
:mnesia.write({:example, 1, 1, 1})
:mnesia.write({:example, 2, 2, 2})
:mnesia.write({:example, 3, 4, 5})
```

## Read

```
:mnesia.dirty_read({:example, 1})
:mnesia.dirty_read({:example, 2})
:mnesia.dirty_read({:example, 3})
```
