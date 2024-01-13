defmodule GlobalCluster.VisitorStore do
  @moduledoc """
  Store to track a number in different regions.
  """
  use Mnesiac.Store
  import Record, only: [defrecord: 3]

  @doc """
  Record definition.
  """
  defrecord(
    :visitor,
    __MODULE__,
    region: nil,
    counter: nil
  )

  @typedoc """
  Record field type definitions.
  """
  @type visitor ::
          record(
            :visitor,
            region: String.t(),
            counter: Integer
          )

  @impl true
  def store_options do
    topology = Application.get_env(:libcluster, :topologies)
    hosts = topology[:epmd][:config][:hosts]

    [
      record_name: :visitor,
      attributes: visitor() |> visitor() |> Keyword.keys(),
      index: [],
      ram_copies: hosts
    ]
  end

  @impl true
  def init_store do
    topology = Application.get_env(:libcluster, :topologies)
    hosts = topology[:epmd][:config][:hosts]

    :mnesia.create_table(Keyword.get(store_options(), :record_name, __MODULE__), store_options())

    # Create an empty record for each node which looks something like this:
    # {:visitor, :"node@ip", 0}
    hosts
    |> Enum.each(fn x ->
      :mnesia.transaction(fn ->
        :mnesia.write({
          :visitor,
          x,
          0
        })
      end)
    end)
  end
end
