defmodule Sideshow.Mixfile do
  use Mix.Project

  def project do
    [app: :sideshow,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps,
     description: description]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :tachometer],
     mod: {Sideshow.Application, []},
     registered: [Sideshow,
                  Sideshow.IsolatedSupervisor]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:tachometer, "~> 0.0.1"},
     {:mock, "~> 0.1.1", only: :test}]
  end

  defp description do
    """
    Background jobs OTP style
    """
  end

  defp package do
    [# These are the default files included in the package
     maintainers: ["Paul Hierommnimon"],
     licenses: ["GNU GPLv3"],
     links: %{"GitHub" => "https://github.com/pavlos/sideshow",
              "Docs" => "https://github.com/pavlos/sideshow"}]
    end
end
