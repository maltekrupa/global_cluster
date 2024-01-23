defmodule GlobalCluster.VisitorCounter do
  @moduledoc """
  Module which increases a counter once a message is received.
  """

  use GenServer

  require Logger

  # Client API

  # https://elixirforum.com/t/creating-a-supervised-global-singleton-genserver/4570
  def start_link(default) do
    case GenServer.start_link(__MODULE__, default, name: {:global, __MODULE__}) do
      {:ok, pid} ->
        Logger.info("---- #{__MODULE__} worker started")
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("---- #{__MODULE__} worker already running")
        {:ok, pid}
    end
  end

  # https://elixirforum.com/t/creating-a-supervised-global-singleton-genserver/4570/4
  def increment(node, name \\ __MODULE__) do
    case GenServer.whereis({:global, name}) do
      nil ->
        Supervisor.restart_child(Elixir.GlobalCluster.Supervisor, GlobalCluster.VisitorCounter)
        GenServer.cast({:global, name}, {:increment, node})

      pid ->
        GenServer.cast(pid, {:increment, node})
    end
  end

  # Server
  @impl GenServer
  def init(_opts) do
    schedule_update()

    {:ok, %{}}
  end

  @impl true
  def handle_cast({:increment, node}, state) do
    state = Map.update(state, node, 1, fn x -> x + 1 end)

    {:noreply, state}
  end

  @impl true
  def handle_info(:update_database, state) do
    state
    |> Enum.each(fn {node, counter} ->
      current_counter_transaction = fn -> :mnesia.read({:visitor, node}) end

      current_counter =
        case :mnesia.transaction(current_counter_transaction) do
          {:atomic, []} -> 0
          {:atomic, x} -> x |> List.first() |> elem(2)
        end

      :mnesia.transaction(fn ->
        :mnesia.write({
          :visitor,
          node,
          current_counter + counter
        })
      end)
    end)

    schedule_update()

    {:noreply, %{}}
  end

  defp schedule_update do
    Process.send_after(self(), :update_database, 1_000)
  end
end
