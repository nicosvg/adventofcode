defmodule Hydro do
  grid = %{}

  def get_high_count(filename) do
    Utils.apply_instructions(filename, &parse_function/1)
  end

  defp parse_function(list) do
    grid =
      list
      |> Enum.map(fn line ->
        line
        |> String.split([",", " -> "])
        |> Enum.map(&String.to_integer/1)
      end)
      |> Enum.reduce(%{}, fn
        [x, y1, x, y2], grid ->
          Enum.reduce(y1..y2, grid, fn y, grid ->
            Map.update(grid, {x, y}, 1, &(&1 + 1))
          end)

        [x1, y, x2, y], grid ->
          Enum.reduce(x1..x2, grid, fn x, grid ->
            Map.update(grid, {x, y}, 1, &(&1 + 1))
          end)

        [x1, y1, x2, y2], grid ->
          Enum.reduce(Enum.zip(x1..x2, y1..y2), grid, fn point, grid ->
            Map.update(grid, point, 1, &(&1 + 1))
          end)

        _, grid ->
          grid
      end)

    grid |> Enum.count(fn {_, v} -> v > 1 end)
  end

  defp set_line({[start_x, start_y], [stop_x, stop_y]}, _acc) do
    cond do
      start_y == stop_y ->
        for x <- start_x..stop_x, do: x

      start_x == stop_x ->
        for y <- start_y..stop_y, do: y

      true ->
        nil
    end
  end
end
