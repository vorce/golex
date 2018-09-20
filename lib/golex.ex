defmodule Golex do
  @moduledoc """
  Game of life
  """
  alias Golex.Cell
  alias Golex.StdoutRender
  alias Golex.World

  @doc """
  Updates a given cell's alive status according to its number of living
  neghbors.
  """
  def cell_tick(%Cell{neighbors: n} = cell) do
    cond do
      n < 2 -> %Cell{cell | alive: false}
      n > 3 -> %Cell{cell | alive: false}
      n == 3 -> %Cell{cell | alive: true}
      true -> cell
    end
  end

  @doc "Return all possible neighbor candidates for the cell"
  def neighbor_candidates(cells, %Cell{position: {cx, cy}}) do
    [
      Map.get(cells, {cx - 1, cy}),
      Map.get(cells, {cx + 1, cy}),
      Map.get(cells, {cx, cy - 1}),
      Map.get(cells, {cx, cy + 1}),
      Map.get(cells, {cx - 1, cy - 1}),
      Map.get(cells, {cx + 1, cy + 1}),
      Map.get(cells, {cx - 1, cy + 1}),
      Map.get(cells, {cx + 1, cy - 1})
    ]
    |> Enum.reject(&(&1 == nil))
  end

  def neighbors([], _) do
    0
  end

  def neighbors(cells, %Cell{position: pos}) do
    length(neighbor_cells(cells, pos))
  end

  def neighbor_cells(cells, pos) do
    Enum.filter(cells, fn cell ->
      neighbor?(cell, pos)
    end)
  end

  defp neighbor?(%Cell{position: {cx, cy}, alive: living}, {x, y}) do
    cond do
      # Dead cells aren't counted as a neighbor
      !living ->
        false

      abs(cx - x) == 1 && abs(cy - y) == 1 ->
        true

      abs(cx - x) == 1 && cy == y ->
        true

      abs(cy - y) == 1 && cx == x ->
        true

      true ->
        false
    end
  end

  @doc """
  Returns a new, evolved world from the specified one.
  """
  def world_tick(%World{cells: cells} = w) do
    %World{w | cells: do_world_tick(cells)}
  end

  defp do_world_tick(cells) do
    Enum.map(cells, fn {pos, cell} ->
      {pos,
       %Cell{cell | neighbors: cells |> neighbor_candidates(cell) |> neighbors(cell)}
       |> cell_tick()}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Returns a new, random world of specified dimensions
  """
  def random_world(width, height) do
    xs = Enum.to_list(0..(width - 1))
    ys = Enum.to_list(0..(height - 1))
    cs = coords(xs, ys)

    %World{
      dimensions: {width, height},
      cells: Enum.map(cs, fn {x, y} -> {{x, y}, new_cell(x, y)} end) |> Enum.into(%{})
    }
  end

  def coords(xs, ys) do
    for y <- ys, x <- xs, do: {x, y}
  end

  @doc """
  Returns a new cell with:
    - random x and y coordinate in the interval 0 to max_x and 0 to max_y.
    - random amount of neighbors in the interval of 0 to 8.
    - alive set to true or false randomly
  """
  def random_cell(max_x, max_y) do
    %Cell{position: {rand(max_x), rand(max_y)}, neighbors: rand(8), alive: rand(1) == 1}
  end

  @doc """
  Returns a new cell with:
    - Position set to x and y,
    - Neighbors set randomly between 0 and 8
    - Alive set to true or false randomly
  """
  def new_cell(x, y) do
    %Cell{position: {x, y}, neighbors: rand(8), alive: rand(1) == 1}
  end

  defp rand(max) do
    :rand.uniform(max + 1) - 1
  end

  def start() do
    myworld = random_world(79, 20)
    StdoutRender.ptl(myworld)
  end
end
