defmodule KeyValue.MixProject do
  use Mix.Project

  def project do
    [
      app: :keyvalue_horde,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KeyValue.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.0"},
      {:horde, "~> 0.4.0-rc.2"}
    ]
  end
end
