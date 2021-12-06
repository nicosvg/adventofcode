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
    Enum.reduce(List.duplicate(0, count), [0, words], &reduce/2)

    |> Enum.at(1)
  end

  def reduce(_e, [index, acc]) do
    bit =
      acc
      |> transpose
      |> Enum.at(index)
      |> get_maj_bit
      IO.inspect(bit, label: "bit")

    filtered = Enum.filter(acc, fn x -> Enum.at(x, index) == bit end)
    IO.inspect(filtered, label: "filtered")
    [index + 1, filtered]
  end

  def get_maj_bit(col) do
    sum = Enum.reduce(col, 0, fn x, acc -> if x == 0, do: acc - 1, else: acc + 1 end)
    if sum >= 0, do: 1, else: 0
  end

  def keep_word(word, majority_bits) do
    Enum.zip(word, majority_bits)
    |> IO.inspect()
    |> Enum.all?(fn {x, y} -> x == y end)
  end

  def transpose(list) do
    Enum.zip_with(list, & &1)
  end
end

Submarine.apply_instructions("test.txt", &Submarine.read_oxygen/1)
|> IO.inspect()
