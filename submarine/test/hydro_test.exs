defmodule HydroTest do
  use ExUnit.Case
  doctest Hydro

  @tag current: true
  test "get high points" do
  count = Hydro.get_high_count("resource/hydro_sample.txt")
  assert count == 5
  end
end
