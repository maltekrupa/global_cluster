# Clust

Global mnesia test cluster.

# Start node

```
iex --name a@127.0.0.1 --cookie super-secret -S mix
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
