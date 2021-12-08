defmodule Utils do
  def transpose(list) do
    Enum.zip_with(list, & &1)
  end

  def apply_instructions(filename, action) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> action.()
  end
end
