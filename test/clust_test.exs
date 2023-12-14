defmodule ClustTest do
  use ExUnit.Case
  doctest Clust

  test "greets the world" do
    assert Clust.hello() == :world
  end
end
