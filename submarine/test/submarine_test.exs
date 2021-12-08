defmodule SubmarineTest do
  use ExUnit.Case
  doctest Submarine

  test "greets the world" do
    assert Submarine.hello() == :world
  end
end
