defmodule MetaProgramming.Assertion do
  @moduledoc """
  Exercises:
  - Implement assert for every operator in Elixir.
  - Add Boolean assertions, such as assert true.
  - Implement a refute macro for refutations.
  And some that are more advanced:
  - Run test cases in parallel within Assertion.T est.run/2 via spawned processes.
  - Add reports for the module. Include pass/fail counts and execution time.
  """
  defmacro __using__(_options \\ []) do
    quote do
      import unquote(__MODULE__)
      # Elixir allows for a tiny amount of mutability here using accumulate: true
      Module.register_attribute(__MODULE__, :tests, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run, do: MetaProgramming.Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)

    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    # bind_quoted is the same as using unquote(operator) ...
    # but if you unquote the same variable multiple times it gets evaluated multiple times.
    # with bind_quoted it only gets evaluated a single time.
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      MetaProgramming.Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end

defmodule MetaProgramming.Assertion.Test do
  def run(tests, module) do
    Enum.each(tests, fn {test_func, description} ->
      case apply(module, test_func, []) do
        :ok ->
          IO.write(".")

        {:fail, reason} ->
          IO.puts("""
          ================================================
          FAILURE: #{description}
          ================================================
          #{reason}
          """)
      end
    end)
  end

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end

  def assert(:==, lhs, rhs) do
    {:fail,
     """
     FAILURE:
       Expected:       #{lhs}
       to be equal to: #{rhs}
     """}
  end

  def assert(:>, lhs, rhs) when lhs == rhs do
    :ok
  end

  def assert(:>, lhs, rhs) do
    {:fail,
     """
     FAILURE:
       Expected:           #{lhs}
       to be greater than: #{rhs}
     """}
  end
end

defmodule MathTest do
  use MetaProgramming.Assertion

  test "integers can be added and subtracted" do
    assert 1 + 1 == 2
    assert 2 + 3 == 5
    assert 5 - 5 == 10
  end

  test "integers can be multiplied and divided" do
    assert 5 * 5 == 25
    assert 10 / 2 == 5
  end
end
