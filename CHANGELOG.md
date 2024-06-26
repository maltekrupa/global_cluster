# Something like a changelog

As soon as the infrastructure was up and running, I started working on the
application. This is what happened.

## 1 - mount function

Diff:
- https://github.com/maltekrupa/global_cluster/commit/c88e8b32ac038391de1bbaecef5ac0dff79faaeb
- `git show c88e8b3`

I added a call to the `increase_counter` function to the mount function of the liveview.

Problems:
- Only seems to work when client makes use of JavaScript (wrk benchmark didn't increase the number) <- not so sure about that.
- Misses requests if you reload fast enough

## 2 - custom plug

Diff:
- https://github.com/maltekrupa/global_cluster/commit/acd5d4eff57ddd55e7d0e8cbc7da773d59aa371f
- `git show acd5d4e`

I moved the function call from the mount function to a custom [Plug](https://hexdocs.pm/phoenix/plug.html).

Now we don't miss a request but it is very slow. wrk measured about 1,5 requests per second.

Problems:
- Request is blocked by mnesia transaction
- Very slow (~1,5 requests per second)

## 3 - genserver

Diff:
- https://github.com/maltekrupa/global_cluster/commit/2d54ac1610bebd494915c727d082332d654cbc35
- `git show 2d54ac1`

I created a singleton GenServer to call the `increase_counter` function. The custom plug is now only used to call the client API of the GenServer.

The requests are not blocked anymore, but the time until all the messages are processed takes around (you might have guessed it already) 1,5 seconds per update.

6k requests of the wrk benchmark took about 1,5*6000 seconds to complete.

Problems:
- Very slow update processing

## 4 - sum up before update

Diff:
- https://github.com/maltekrupa/global_cluster/commit/8d8e1ee062e07998b315607b56981657a4d2891b
- `git show 8d8e1ee`

I added a dedicated state and a scheduled update to the GenServer.
The state takes care of all the incoming messages and sums them up per node. The scheduled update only runs once per second and then adds the sum of the state to the sum which is already in the database.

Instead of two transactions per request we now have eight transactions every second (number of nodes times two).

One for each node to get the current state and one for each node to update the number in the database.

Problem:
- rather slow because of the amount of transactions

## 5 - reduce complexity (reverted)

Diff:
- https://github.com/maltekrupa/global_cluster/commit/8e5bbc6840007062bef9b12aa4f047fbd9321586
- `git show 8a51338`

Instead of multiple transactions, make use of a single :ets.update_counter.

Problem:
- :ets.update_counter is not a transaction and is only available on the node it
  was run on. All other nodes do not receive the update.

## 6 - reduce amount of transactions

Diff:
- https://github.com/maltekrupa/global_cluster/commit/1c948629f8f04d6e922115b531e084923c0c82cf
- `git show 1c94862`

ChatGPT taught me something obvious: I can do more than just call :mnesia.(read|write) in a transaction. m(
Instead of two transactions I reduced it to one.

Problem:
- We still create one transaction per node

## 7 - refactor mnesiac store init

Diff
- https://github.com/maltekrupa/global_cluster/commit/76e20db907bdce3a811b5d1019b1323fc43676e9
- `git show 76e20db`

Whenever a node restarted (for whatever reason) it re-initialized the store
which set every record to zero. This is now fixed and the counter just keeps on growing.

Not even a deployment should reset the counter now. I think.

Problem:
- Too many transactions (one per node) which update the counter too slow

## 8 - show active users

Diff
- https://github.com/maltekrupa/global_cluster/commit/2058068aebc3aa6097efc9a9b7c2c557fedb02eb
- https://github.com/maltekrupa/global_cluster/commit/e9bd2276c9b21ea8a15f59070fe9c05291aaebf2
- `git show 2058068`
- `git show e9bd227`

Phoenix Presence is now part of the application. It shows the current amount of
active users on each node.

## Next

The next iteration should reduce the amount of transactions to one.

