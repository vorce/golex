defmodule Golex.StdoutRender do
  @moduledoc """
  Renders the game of life to stdout
  """
  alias Golex.World
  alias Golex.Cell

  def world_string(%World{dimensions: {w, h}, cells: cells}) do
    xs = Enum.to_list(0..(w - 1))
    ys = Enum.to_list(0..(h - 1))
    cs = Golex.coords(xs, ys)

    Enum.map(cs, fn pos ->
      cell_string(w, Map.get(cells, pos))
    end)
  end

  defp cell_string(width, %Cell{position: {x, _}, alive: living}) do
    cond do
      x + 1 == width && living -> "#\n"
      x + 1 == width && !living -> ".\n"
      living -> "#"
      true -> "."
    end
  end

  # Print, tick, loop
  def ptl(world) do
    IO.puts(world_string(world))
    IO.gets("-- press enter for next tick --")

    world
    |> Golex.world_tick()
    |> ptl()
  end
end
