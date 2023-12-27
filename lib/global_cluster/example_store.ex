defmodule GlobalCluster.ExampleStore do
  @moduledoc """
  Provides the structure of ExampleStore records for a minimal example of Mnesiac.
  """
  use Mnesiac.Store
  import Record, only: [defrecord: 3]

  @doc """
  Record definition for ExampleStore example record.
  """
  defrecord(
    :example,
    __MODULE__,
    id: nil,
    topic_id: nil,
    event: nil
  )

  @typedoc """
  ExampleStore example record field type definitions.
  """
  @type example ::
          record(
            :example,
            id: String.t(),
            topic_id: String.t(),
            event: String.t()
          )

  @impl true
  def store_options do
    topology = Application.get_env(:libcluster, :topologies)
    hosts = topology[:epmd_example][:config][:hosts]

    [
      record_name: :example,
      attributes: example() |> example() |> Keyword.keys(),
      index: [:topic_id],
      disc_copies: hosts
    ]
  end
end
