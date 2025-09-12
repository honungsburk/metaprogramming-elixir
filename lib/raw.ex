defmodule MetaProgramming.Raw do
  defmacro add(x, y) do
    {:+, [context: Elixir, imports: [{1, Kernel}, {2, Kernel}]], [x, y]}
  end
end
