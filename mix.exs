defmodule PhoenixGuardian.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_guardian,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PhoenixGuardian, []},
      applications: applications(Mix.env)
    ]
  end

  def applications(env) when env in [:test] do
    applications(:default) ++ [:ex_machina]
  end

  def applications(_) do
    [
      :comeonin,
      :cowboy,
      :ecto,
      :logger,
      :oauth2,
      :phoenix,
      :phoenix_ecto,
      :phoenix_html,
      :postgrex,
      :ueberauth,
      :ueberauth_facebook,
      :ueberauth_github,
      :ueberauth_google,
      :ueberauth_identity,
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:ex_machina, "~> 2.1", only: [:dev, :test]},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix, "~> 1.3.0"},
     {:phoenix_ecto, "~> 3.2"},
     {:phoenix_html, "~> 2.10"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:postgrex, ">= 0.11.1"},
     {:guardian_db, "~> 0.8"},
     {:guardian, "~> 0.14"},
     {:ueberauth, "~> 0.4"},
     {:ueberauth_github, "~> 0.4"},
     {:ueberauth_identity, "~> 0.2"},
     {:ueberauth_google, "~> 0.5"},
     {:ueberauth_facebook, "~> 0.7"},
     {:comeonin, "~> 4.0"},
     {:bcrypt_elixir, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     test: [&setup_db/1, "test"]]
  end

  defp setup_db(_) do
    # Create the database, run migrations
    Mix.Task.run "ecto.drop"#, ["--quiet"]
    Mix.Task.run "ecto.create"#, ["--quiet"]
    Mix.Task.run "ecto.migrate"#, ["--quiet"]
  end
end
