defmodule SimuTraffic.MixProject do
  use Mix.Project

  def project do
    [
      app: :simu_traffic,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SimuTraffic.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nestru, "~> 0.3.2"},
      {:jason, "~> 1.4.0"},
      {:httpoison, "~> 2.1.0"}
    ]
  end
end
