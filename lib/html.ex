defmodule MetaProgramming.Html do
  @external_resource tags_path = Path.join([__DIR__, "../priv/tags.txt"])
  @tags (for line <- File.stream!(tags_path, [], :line) do
           line |> String.trim() |> String.to_atom()
         end)

  defmacro markup(do: block) do
    quote do
      {:ok, var!(buffer, MetaProgramming.Html)} = start_buffer([])
      unquote(Macro.postwalk(block, &postwalk/1))
      result = render(var!(buffer, MetaProgramming.Html))
      :ok = stop_buffer(var!(buffer, MetaProgramming.Html))
      result
    end
  end

  def postwalk({:text, _meta, [string]}) do
    quote do: put_buffer(var!(buffer, MetaProgramming.Html), to_string(unquote(string)))
  end

  def postwalk({tag_name, _meta, [[do: inner]]}) when tag_name in @tags do
    quote do: tag(unquote(tag_name), [], do: unquote(inner))
  end

  def postwalk({tag_name, _meta, [attrs, [do: inner]]}) when tag_name in @tags do
    quote do: tag(unquote(tag_name), unquote(attrs), do: unquote(inner))
  end

  def postwalk(ast), do: ast

  def start_buffer(state), do: Agent.start_link(fn -> state end)

  def stop_buffer(buffer), do: Agent.stop(buffer)

  def put_buffer(buffer, content), do: Agent.update(buffer, fn state -> [content | state] end)

  def render(buffer), do: Agent.get(buffer, & &1) |> Enum.reverse() |> Enum.join("")

  defmacro tag(name, attrs \\ []) do
    {inner, attrs} = Keyword.pop(attrs, :do)
    quote do: tag(unquote(name), unquote(attrs), do: unquote(inner))
  end

  defmacro tag(name, attrs, do: inner) do
    quote do
      put_buffer(var!(buffer, MetaProgramming.Html), open_tag(unquote_splicing([name, attrs])))
      unquote(inner)
      put_buffer(var!(buffer, MetaProgramming.Html), "</#{unquote(name)}>")
    end
  end

  def open_tag(name, []) do
    "<#{name}>"
  end

  def open_tag(name, attrs) do
    attr_html = for {key, val} <- attrs, into: "", do: "#{key}=\"#{val}\""
    "<#{name} #{attr_html}>"
  end

  defmacro text(content) do
    quote do
      put_buffer(var!(buffer, MetaProgramming.Html), to_string(unquote(content)))
    end
  end
end

defmodule MetaProgramming.Template do
  import MetaProgramming.Html

  def render1 do
    markup do
      tag :table do
        tag :tr do
          for i <- 0..5 do
            tag :td do
              text("Cell #{i}")
            end
          end
        end
      end

      tag :div do
        text("Some Nested Content")
      end
    end
  end

  def render2 do
    markup do
      table do
        tr do
          for i <- 0..5 do
            td do
              text("Cell #{i}")
            end
          end
        end
      end

      div do
        text("Some Nested Content")
      end
    end
  end

  def render3 do
    markup do
      div id: "main" do
        h1 class: "title" do
          text("Welcome!")
        end
      end

      div class: "row" do
        div do
          p(do: text("Hello!"))
        end
      end
    end
  end
end
