defmodule MetaProgramming.LoopTest do
  use ExUnit.Case
  import MetaProgramming.Loop

  test "Is it really that easy?" do
    assert Code.ensure_loaded?(MetaProgramming.Loop)
  end

  test "while/2 loops as long as the expression is truthy" do
    pid = spawn(fn -> :timer.sleep(:infinity) end)

    send(self(), :one)

    while Process.alive?(pid) do
      receive do
        :one ->
          send(self(), :two)

        :two ->
          send(self(), :three)

        :three ->
          Process.exit(pid, :kill)
          send(self(), :done)
      end
    end

    assert_received :done
    refute Process.alive?(pid)
  end
end
