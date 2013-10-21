defmodule Golex do
  defrecord Cell, position: [], neighbors: 0, alive: false
  defrecord World, dimensions: [], cells: []
 
  @doc """
  Updates a given cell's alive status according to its number of living
  neghbors.
  """
  def cell_tick(Cell[neighbors: n] = cell) do
    cond do
      n < 2 -> cell.alive(false)
      n > 3 -> cell.alive(false)
      n == 3 -> cell.alive(true)
      true -> cell
    end
  end

  def neighbors([], _) do
    0
  end

  def neighbors(world, Cell[position: pos]) do
    length neighbor_cells(world, pos)
  end

  def neighbor_cells(world, pos) do
    Enum.filter world, fn(cell) -> 
      neighbor? cell, pos
    end
  end

  defp neighbor?(Cell[position: [cx, cy], alive: living], [x, y]) do
    cond do
      !living -> false # Dead cells aren't counted as neighbors
      abs(cx - x) == 1 && abs(cy - y) == 1 -> true
      abs(cx - x) == 1 && cy == y -> true
      abs(cy - y) == 1 && cx == x -> true
      true -> false
    end
  end

  @doc """
  Returns a new world (list of cells) from the specified one, evolved.
  """
  def world_tick(World[dimensions: dim, cells: cells]) do
    World[dimensions: dim, cells: do_world_tick(cells)]
  end

  defp do_world_tick(cells) do
    Enum.map cells, fn(cell) ->
      neighbors(cells, cell) |> cell.neighbors |> cell_tick
    end
  end

  @doc """
  Returns a new, random world of specified dimensions
  """
  def random_world(width, height) do
    xs = Enum.to_list(0..width - 1)
    ys = Enum.to_list(0..height - 1)
    cs = coords(xs, ys)
    World[dimensions: [width, height], cells: Enum.map(cs, fn({x, y}) -> new_cell(x, y) end)]
  end

  defp coords(xs, ys) do
    #lc x inlist xs, x, y inlist ys, do: {x, y}
    lc y inlist ys, y, x inlist xs, do: {x, y}
  end

  @doc """
  Returns a new cell with:
    - random x and y coordinate in the interval 0 to max_x and 0 to max_y.
    - random amount of neighbors in the interval of 0 to 8.
    - alive set to true or false randomly
  """
  def random_cell(max_x, max_y) do
    Cell[position: [rand(max_x), rand(max_y)],
          neighbors: rand(8),
          alive: rand(1) == 1]
  end

  @doc """
  Returns a new cell with:
    - Position set to x and y,
    - Neighbors set randomly between 0 and 8
    - Alive set to true or false randomly
  """
  def new_cell(x, y) do
    Cell[position: [x, y],
          neighbors: rand(8),
          alive: rand(1) == 1]
  end

  defp rand(max) do
    :random.uniform(max + 1) - 1
  end

  def world_string(World[cells: []], acc) do
    acc
  end

  def world_string(World[dimensions: [w, he], cells: [h | t]], acc) do
    world_string(World[dimensions: [w, he], cells: t],
                  acc ++ [cell_string(w, h)])
  end

  defp cell_string(width, Cell[position: [x, _], alive: living]) do
    cond do
      x + 1 == width && living -> "#\n"
      x + 1 == width && !living -> ".\n"
      living -> "#"
      true -> "."
    end
  end

  # Print, tick, loop
  defp ptl(world) do
    IO.puts world_string(world, [])
    IO.gets("-----------")
    world_tick(world) |> ptl
  end

  def start(_opts // []) do
    myworld = random_world(79, 20) # 80, 20)
    ptl(myworld)
  end
end
