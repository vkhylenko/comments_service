defmodule CommentsMicroservice.MixProject do
  use Mix.Project

  def project do
    [
      app: :comments_microservice,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,  #starts your application as :permanent, if app terminates, all other applications and the entire node are also terminated
      deps: deps()
    ]
  end


  def application do
    [
      extra_applications: [:logger, :kaffe, :crypto],
      mod: {CommentsMicroservice.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:httpoison, ">= 1.6.2"},
      {:poison, ">= 4.0.1"},
      {:kaffe, "~> 1.9"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:distillery, "~> 2.1"}
    ]
  end
end
