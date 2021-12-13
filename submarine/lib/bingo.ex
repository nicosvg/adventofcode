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

  def find_last_bingo_winner(list) do
    [draw, grids] = parse_bingo(list)
    res = Enum.map(grids, fn g -> {:lost, g} end)

    Enum.reduce_while(draw, res, &reduce_last_winner/2)
  end

  def reduce_last_winner(element, grids) do
    results =
      grids
      |> Enum.map(&update_grid_and_check_result(&1, element))

    winnerNumber = Enum.count(results, fn {result, _} -> result != :lost end)

    if Enum.count(grids) == winnerNumber do
      {:winning, loserGrid} = Enum.find(results, fn {result, _} -> result == :winning end)
      sum = loserGrid |> Enum.filter(fn x -> x != nil end) |> Enum.sum()
      {:halt, {loserGrid, sum, element, sum * element}}
    else
      {:cont, results}
    end
  end

  def reduce(element, grids) do
    result =
      grids
      |> Enum.map(&update_grid_and_check(&1, element))

    updated =
      result
      |> Enum.map(fn {result, grid} -> grid end)

    winner = Enum.find(result, fn {result, _} -> result == :winning end)

    if winner != nil do
      {:winning, winnerGrid} = winner
      sum = winnerGrid |> Enum.filter(fn x -> x != nil end) |> Enum.sum()
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
      |> Utils.transpose()
      |> Enum.any?(fn row -> Enum.all?(row, fn x -> x == nil end) end)

      case result_col || result_row do
        true -> {:winning, updated}
        false -> {:lost, updated}
      end
  end

  def update_grid_and_check_result({status, grid}, number) do
    case status do
      :winning -> {:won, grid}
      :won -> {:won, grid}
      :lost -> update_grid_and_check(grid, number)
    end
  end
end
