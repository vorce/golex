defmodule GolexTest do
  use ExUnit.Case, async: true

  alias Golex.Cell, as: Cell
  alias Golex.World, as: World

  @cell1 Cell[position: [1, 1], neighbors: -1, alive: true]
  @cell2 Cell[position: [0, 1], neighbors: 2, alive: true]
  @cell3 Cell[position: [0, 0], neighbors: 4, alive: true]
  @cell4 Cell[position: [0, 2], neighbors: 3, alive: true]
  @cell5 Cell[position: [1, 0], neighbors: 0, alive: true]

  test "Any live cell with fewer than two live neighbours dies, as if caused by under-population." do
    assert Golex.cell_tick(@cell1) ==
      Cell[position: @cell1.position,
            neighbors: @cell1.neighbors,
            alive: false]
  end

  test "Any live cell with two or three live neighbours lives on to the next generation." do
  assert Golex.cell_tick(@cell2) ==
    Cell[position: @cell2.position,
          neighbors: @cell2.neighbors,
          alive: true]
  end

  test "Any live cell with more than three live neighbours dies, as if by overcrowding." do
    assert Golex.cell_tick(@cell3) ==
      Cell[position: @cell3.position,
            neighbors: @cell3.neighbors,
            alive: false] 
  end

  test "Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
    assert Golex.cell_tick(@cell4) ==
      Cell[position: @cell4.position,
            neighbors: @cell4.neighbors,
            alive: true]
  end

  test "Dead cell with two neighbors should not come alive" do
    cell = Cell[position: [], neighbors: 2, alive: false]
    assert Golex.cell_tick(cell) == cell
  end

  test "Neighbors in empty world should be 0" do
    assert Golex.neighbors([], @cell1) == 0
  end

  test "Neighbors with 1 neighbors" do
    assert Golex.neighbors([@cell2], @cell1) == 1
  end

  test "Neighbors with 2 neighbors" do
    assert Golex.neighbors([@cell3, @cell4], @cell2) == 2
  end

  test "World tick kills lonely cell" do
    assert Golex.world_tick(World[cells: [@cell2]]) ==
      World[cells: [Cell[position: @cell2.position,
            neighbors: 0,
            alive: false]]
          ]
  end

  test "World tick kills crowded cells" do
    w = World[cells: [@cell3, @cell5, @cell2, @cell1, @cell4]]
    assert Golex.world_tick(w) ==
            World[cells: [
              Golex.Cell[position: [0, 0], neighbors: 3, alive: true],
              Golex.Cell[position: [1, 0], neighbors: 3, alive: true],
              Golex.Cell[position: [0, 1], neighbors: 4, alive: false],
              Golex.Cell[position: [1, 1], neighbors: 4, alive: false],
              Golex.Cell[position: [0, 2], neighbors: 2, alive: true]]
            ]
  end

  test "Cells should die in world with few living neighbors" do
    w = World[cells: [@cell3.alive(false), @cell5.alive(false), @cell2, @cell1, @cell4.alive(false)]]
    assert Golex.world_tick(w) ==
            World[cells: [
              Golex.Cell[position: [0, 0], neighbors: 2, alive: false],
              Golex.Cell[position: [1, 0], neighbors: 2, alive: false],
              Golex.Cell[position: [0, 1], neighbors: 1, alive: false],
              Golex.Cell[position: [1, 1], neighbors: 1, alive: false],
              Golex.Cell[position: [0, 2], neighbors: 2, alive: false]]
            ]
  end

  test "Dead cells should not be counted as neighbors" do
    w =  [@cell3.alive(false), @cell5.alive(false), @cell2,
          @cell1, @cell4.alive(false)]
    assert Golex.neighbors(w, @cell2) == 1
  end

  test "Should get random, non empty, world" do
    w = Golex.random_world(80, 20)
    assert length(w.cells) == 1600 
    assert Enum.first(w.dimensions) == 80
    assert Enum.at(w.dimensions, 1) == 20
  end

  test "Should get random cell within bounds" do
    cs = Stream.repeatedly(fn -> Golex.random_cell(10, 10) end) |> Enum.take(10)
    Enum.each(cs, fn(x) ->
      xp = Enum.first(x.position)
      yp = Enum.at(x.position, 1)
      assert xp >= 0
      assert xp <= 10
      assert yp >= 0
      assert yp <= 10
    end)
  end

  test "Should get new cell with specified position" do
    c = Golex.new_cell(1337, 42)
    assert Enum.first(c.position) == 1337
    assert Enum.at(c.position, 1) == 42
  end

  test "Should have new line after each row" do
    width = 4
    ws = Golex.world_string(Golex.random_world(width, 3), [])
    assert String.ends_with?(Enum.at(ws, width - 1), "\n")
  end
end
