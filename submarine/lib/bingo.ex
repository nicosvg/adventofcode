defmodule Bingo do
  def parse_bingo(list) do
    [numbers | gridsString] = list

    draw =
      numbers
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    grids =
      gridsString
      |> Enum.map(&parse_grid_line/1)
      |> Enum.chunk_every(5)
      |> Enum.map(&Enum.concat/1)

    [draw, grids]
  end

  def parse_grid_line(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def find_bingo_winner(list) do
    [draw, grids] = parse_bingo(list)
    Enum.reduce_while(draw, grids, &reduce/2)
  end

  def reduce(element, grids) do
    result =
      grids
      |> Enum.map(&update_grid_and_check(&1, element))

    updated =
      result
      |> Enum.map(fn {result, grid} -> grid end)

    winner = Enum.find(result, fn {result, _} -> result == true end)

    if winner != nil do
      {true, winnerGrid} = winner
      sum = winnerGrid |> Enum.filter(fn x -> x != nil end) |> Enum.sum
      {:halt, {winnerGrid, sum, element, sum * element}}
    else
      {:cont, updated}
    end
  end

  def update_grid_and_check(grid, number) do
    updated = Enum.map(grid, fn x -> if x == number, do: nil, else: x end)

    result_row =
      updated
      |> Enum.chunk_every(5)
      |> Enum.any?(fn row -> Enum.all?(row, fn x -> x == nil end) end)

    result_col =
      updated
      |> Enum.chunk_every(5)
      |> Utils.transpose
      |> Enum.any?(fn row -> Enum.all?(row, fn x -> x == nil end) end)

    {result_row || result_col, updated}
  end

end
