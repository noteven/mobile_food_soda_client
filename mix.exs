defmodule MobileFoodSodaClient.MixProject do
  use Mix.Project

  @description """
  Client library for accessing City of San Fanciscos SODA API for Mobile Food
  Facility Permit data-set.
  """
  @version "0.0.1"
  @repo_url "https://github.com/noteven/mobile_food_soda_client"

  def project do
    [
      app: :mobile_food_soda_client,
      description: @description,
      version: @version,
      source_url: @repo_url,
      homepage_url: @repo_url,
      package: package(),
      docs: docs(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test
      ],
      deps: deps(),
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def docs do
    [
      name: "MobileFoodSODAClient",
      extras: ["README.md"],
      main: "README",
      source_url: @repo_url
    ]
  end

  def package do
    [
      name: :mobile_food_soda_client,
      description: @description,
      maintainers: [],
      licenses: ["MIT"],
      files: ["lib/*", "mix.exs", "README*", "LICENSE*"],
      links: %{
        "GitHub" => @repo_url
      }
    ]
  end

  defp elixirc_paths(:test), do: ["test/support"] ++ elixirc_paths(:prod)
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Test dependencies
      {:propcheck, "~> 1.4", only: [:test, :dev]},
      {:excoveralls, "~> 0.10", only: [:test]},

      # Dev dependencies
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "compile --warnings-as-errors",
        "credo --all --strict",
        "dialyzer --format short"
      ]
    ]
  end
end
