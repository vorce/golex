defmodule GolexTest do
  use ExUnit.Case, async: true

  alias Golex.Cell
  alias Golex.World

  @cell1 %Cell{position: {1, 1}, neighbors: -1, alive: true}
  @cell2 %Cell{position: {0, 1}, neighbors: 2, alive: true}
  @cell3 %Cell{position: {0, 0}, neighbors: 4, alive: true}
  @cell4 %Cell{position: {0, 2}, neighbors: 3, alive: true}
  @cell5 %Cell{position: {1, 0}, neighbors: 0, alive: true}

  test "Any live cell with fewer than two live neighbours dies, as if caused by under-population." do
    assert Golex.cell_tick(@cell1) == %Cell{position: @cell1.position, neighbors: @cell1.neighbors, alive: false}
  end

  test "Any live cell with two or three live neighbours lives on to the next generation." do
    assert Golex.cell_tick(@cell2) == %Cell{position: @cell2.position, neighbors: @cell2.neighbors, alive: true}
  end

  test "Any live cell with more than three live neighbours dies, as if by overcrowding." do
    assert Golex.cell_tick(@cell3) == %Cell{position: @cell3.position, neighbors: @cell3.neighbors, alive: false}
  end

  test "Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
    assert Golex.cell_tick(@cell4) == %Cell{position: @cell4.position, neighbors: @cell4.neighbors, alive: true}
  end

  test "Dead cell with two neighbors should not come alive" do
    cell = %Cell{position: [], neighbors: 2, alive: false}
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
    # %Cell{position: @cell2.position, neighbors: 0, alive: false}
    assert Golex.world_tick(%World{cells: %{@cell1.position => @cell2}}) == %Golex.World{
             cells: %{
               @cell1.position => %Golex.Cell{
                 alive: false,
                 neighbors: 0,
                 position: @cell2.position
               }
             }
           }
  end

  test "World tick kills crowded cells" do
    w = %World{
      cells: %{
        @cell3.position => @cell3,
        @cell5.position => @cell5,
        @cell2.position => @cell2,
        @cell1.position => @cell1,
        @cell4.position => @cell4
      }
    }

    assert Golex.world_tick(w) == %Golex.World{
             cells: %{
               {0, 0} => %Golex.Cell{alive: true, neighbors: 3, position: {0, 0}},
               {0, 1} => %Golex.Cell{alive: false, neighbors: 4, position: {0, 1}},
               {0, 2} => %Golex.Cell{alive: true, neighbors: 2, position: {0, 2}},
               {1, 0} => %Golex.Cell{alive: true, neighbors: 3, position: {1, 0}},
               {1, 1} => %Golex.Cell{alive: false, neighbors: 4, position: {1, 1}}
             }
           }
  end

  test "Cells should die in world with few living neighbors" do
    w = %World{
      cells: %{
        @cell3.position => %Cell{@cell3 | alive: false},
        @cell5.position => %Cell{@cell5 | alive: false},
        @cell2.position => @cell2,
        @cell1.position => @cell1,
        @cell4.position => %Cell{@cell4 | alive: false}
      }
    }

    assert Golex.world_tick(w) ==
             %World{
               cells: %{
                 {0, 0} => %Cell{position: {0, 0}, neighbors: 2, alive: false},
                 {1, 0} => %Cell{position: {1, 0}, neighbors: 2, alive: false},
                 {0, 1} => %Cell{position: {0, 1}, neighbors: 1, alive: false},
                 {1, 1} => %Cell{position: {1, 1}, neighbors: 1, alive: false},
                 {0, 2} => %Cell{position: {0, 2}, neighbors: 2, alive: false}
               }
             }
  end

  test "Dead cells should not be counted as neighbors" do
    cs = [
      %Cell{@cell3 | alive: false},
      %Cell{@cell5 | alive: false},
      @cell2,
      @cell1,
      %Cell{@cell4 | alive: false}
    ]

    assert Golex.neighbors(cs, @cell2) == 1
  end

  test "Should get random, non empty, world" do
    w = Golex.random_world(80, 20)
    assert Map.size(w.cells) == 1600
    assert w.dimensions == {80, 20}
  end

  test "Should get random cell within bounds" do
    cs = Stream.repeatedly(fn -> Golex.random_cell(10, 10) end) |> Enum.take(10)

    Enum.each(cs, fn x ->
      {xp, yp} = x.position
      assert xp >= 0
      assert xp <= 10
      assert yp >= 0
      assert yp <= 10
    end)
  end

  test "Should get new cell with specified position" do
    c = Golex.new_cell(1337, 42)
    assert {1337, 42} == c.position
  end

  test "Should have new line after each row" do
    width = 4
    ws = Golex.world_string(Golex.random_world(width, 3), [])
    assert String.ends_with?(Enum.at(ws, width - 1), "\n")
  end
end
