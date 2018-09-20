defmodule Golex.Cell do
  @moduledoc """
  A cell in the world
  """
  defstruct position: {0, 0}, neighbors: 0, alive: false
end
