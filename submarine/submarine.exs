defmodule Submarine do
  def apply_instructions(filename, action) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> action.()
  end

  def count_depth(list) do
    list
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.filter(fn [x, y] -> y > x end)
    |> Enum.count()
  end

  def count_all(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.filter(fn [x, y] -> y > x end)
    |> Enum.count()
  end

  def update_positions(instructions) do
    instructions
    |> Enum.map(fn i -> i |> String.split(" ") end)
    |> Enum.reduce([0, 0, 0], &reduce_moves/2)
  end

  def reduce_moves([command, valueString], [depth, horizontal, aim]) do
    {value, _} = Integer.parse(valueString)

    case command do
      "forward" -> [depth + aim * value, horizontal + value, aim]
      "up" -> [depth, horizontal, aim - value]
      "down" -> [depth, horizontal, aim + value]
    end
  end

  def read_diag(list) do
    list
    |> Enum.map(&parse_diag_line/1)
    |> Enum.reduce(List.duplicate(0, 12), &reduce_diag/2)
    |> IO.inspect(label: "scores")
    |> Enum.map(fn x -> if x >= 1, do: 1, else: 0 end)
  end

  def parse_diag_line(line) do
    line
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end

  def reduce_diag(element, acc) do
    Enum.zip_with([element, acc], fn [x, y] -> if x == 0, do: y - 1, else: y + 1 end)
  end

  def read_oxygen(list) do
    words = list |> Enum.map(&parse_diag_line/1)
    length = Enum.count(Enum.at(words, 1))

    Enum.reduce_while(List.duplicate(0, length), [0, words], &filter_oxygen/2)
    |> Enum.at(1)
  end

  def read_dioxyde(list) do
    words = list |> Enum.map(&parse_diag_line/1)
    length = Enum.count(Enum.at(words, 1))

    Enum.reduce_while(List.duplicate(0, length), [0, words], &filter_dioxyde/2)
    |> Enum.at(1)
  end

  def filter_oxygen(_e, [index, acc]) do
    bit =
      acc
      |> transpose
      |> Enum.at(index)
      |> get_maj_bit

    IO.inspect(bit, label: "bit")

    filtered = Enum.filter(acc, fn x -> Enum.at(x, index) == bit end)
    IO.inspect(filtered, label: "filtered")

    if Enum.count(filtered) == 1 do
      {:halt, [index + 1, filtered]}
    else
      {:cont, [index + 1, filtered]}
    end
  end

  def filter_dioxyde(_e, [index, acc]) do
    bit =
      acc
      |> transpose
      |> Enum.at(index)
      |> get_min_bit

    filtered = Enum.filter(acc, fn x -> Enum.at(x, index) == bit end)

    if Enum.count(filtered) == 1 do
      {:halt, [index + 1, filtered]}
    else
      {:cont, [index + 1, filtered]}
    end
  end

  def get_maj_bit(col) do
    sum = Enum.reduce(col, 0, fn x, acc -> if x == 0, do: acc - 1, else: acc + 1 end)
    if sum >= 0, do: 1, else: 0
  end

  def get_min_bit(col) do
    get_maj_bit(col) * -1 + 1
  end

  def keep_word(word, majority_bits) do
    Enum.zip(word, majority_bits)
    |> IO.inspect()
    |> Enum.all?(fn {x, y} -> x == y end)
  end

  def transpose(list) do
    Enum.zip_with(list, & &1)
  end

  def parse_bingo(list) do
    [numbers | gridsString] = list

    draw =
      numbers
      |> String.split(",")
      |> IO.inspect()
      |> Enum.map(&String.to_integer/1)

    IO.inspect(draw, label: "draw")

    grids =
      gridsString
      |> Enum.map(&parse_grid_line/1)
      |> Enum.chunk_every(5)
      |> Enum.map(&Enum.concat/1)

    IO.inspect(grids, label: "grids")
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
      |> IO.inspect()

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
      |> transpose
      |> Enum.any?(fn row -> Enum.all?(row, fn x -> x == nil end) end)

    {result_row || result_col, updated}
  end
end

Submarine.apply_instructions("bingo.txt", &Submarine.find_bingo_winner/1)
|> IO.inspect(label: "final result")
