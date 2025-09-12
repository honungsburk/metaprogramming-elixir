defmodule MetaProgramming.Setter do
  defmacro bind_name1(string) do
    quote do
      name = unquote(string)
    end
  end

  defmacro bind_name2(string) do
    quote do
      var!(name) = unquote(string)
    end
  end
end
