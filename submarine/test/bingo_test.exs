defmodule BingoTest do
  use ExUnit.Case
  doctest Bingo

  test "get bingo winner" do
    {grid, sum, number, product} =
      Utils.apply_instructions("resource/bingo.txt", &Bingo.find_bingo_winner/1)

    IO.inspect(grid, label: "grid")
    IO.inspect(sum, label: "sum")
    IO.inspect(number, label: "number")
    IO.inspect(product, label: "product")

    assert product == 8580
  end

  test "get bingo last winner" do
    {grid, sum, number, product} =
      Utils.apply_instructions("resource/bingo_sample.txt", &Bingo.find_last_bingo_winner/1)

    IO.inspect(grid, label: "grid")
    IO.inspect(sum, label: "sum")
    IO.inspect(number, label: "number")
    IO.inspect(product, label: "product")

    assert product == 1924
  end
end
