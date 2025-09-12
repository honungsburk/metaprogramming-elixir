defmodule MetaProgramming.MixProject do
  use Mix.Project

  def project do
    [
      app: :meta_programming,
      version: "0.1.0",
      elixir: "~> 1.18",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MetaProgramming.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.15"}
    ]
  end
end
