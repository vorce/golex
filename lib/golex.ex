defmodule Golex do
  @doc """
  Updates a given cell's alive status according to its number of living
  neghbors.
  """
  alias Golex.Cell
  alias Golex.World

  def cell_tick(%Cell{neighbors: n} = cell) do
    cond do
      n < 2 -> %Cell{cell | alive: false}
      n > 3 -> %Cell{cell | alive: false}
      n == 3 -> %Cell{cell | alive: true}
      true -> cell
    end
  end

  @doc "Narrow down the neighbor candidates"
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
      # Dead cells aren't counted as neighbors
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
  Returns a new world (list of cells) from the specified one, evolved.
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

  defp coords(xs, ys) do
    # lc y inlist ys, y, x inlist xs, do: {x, y}
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

  def world_string(%World{dimensions: {w, h}, cells: cells}, []) do
    xs = Enum.to_list(0..(w - 1))
    ys = Enum.to_list(0..(h - 1))
    cs = coords(xs, ys)

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
  defp ptl(world) do
    IO.puts(world_string(world, []))
    IO.gets("-----------")
    world_tick(world) |> ptl
  end

  def start() do
    # 80, 20)
    myworld = random_world(79, 20)
    ptl(myworld)
  end
end
