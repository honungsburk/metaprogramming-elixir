defmodule MetaProgramming.ControlFlow do
  defmacro unless(expression, do: block) do
    quote do
      if !unquote(expression), do: unquote(block)
    end
  end

  defmacro unless2(expression, do: block) do
    quote do
      case unquote(expression) do
        x when x in [nil, false] -> unquote(block)
        _ -> nil
      end
    end
  end

  defmacro my_if(expr, do: if_block), do: if(expr, do: if_block, else: nil)

  defmacro my_if(expr, do: if_block, else: else_block) do
    quote do
      case unquote(expr) do
        result when result in [false, nil] -> unquote(else_block)
        _ -> unquote(if_block)
      end
    end
  end
end
