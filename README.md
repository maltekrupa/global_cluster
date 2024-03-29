# Global Cluster

Counting visitors on a shared and distributed global datastore.

See it live at [gc.nafn.de](http://gc.nafn.de).

Since this demo costs money and does not serve a purpose, I might take it down
at any moment.

If it really is down, check out some archived links:
- https://archive.ph/UFfC2
- https://web.archive.org/web/20240327135802/http://eu-central-1.gc.nafn.de/

# FAQ and changelog

People on
[reddit](https://www.reddit.com/r/elixir/comments/1bp3l45/im_learning_elixir_and_built_a_website_with_a/)
asked some questions. You can find everything in the [FAQ](FAQ.md)

There is also a [changelog](CHANGELOG.md) if you're interested.

# Local development

If you only need one node, start it via:

```
mix phx.server
```

If you need multiple nodes, start each of them in a terminal with a different
port using the `PORT` environment variable (`4000` by default):

```
iex --name a@127.0.0.1 -S mix phx.server
```

```
PORT=4001 iex --name b@127.0.0.1 -S mix phx.server
```

Afterwards libcluster should take care of forming a cluster and mnesiac should
form a mnesia cluster.
