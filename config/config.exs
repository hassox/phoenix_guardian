# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :phoenix_guardian, PhoenixGuardian.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "m6b9EGgoTxATviy/Ujx2stZC8UXkw2MMXACAXQR1btpZtV+FtQfl9kL7WoU5mvrD",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: PhoenixGuardian.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :guardian, Guardian,
  issuer: "PhoenixGuardian.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true,
  serializer: PhoenixGuardian.GuardianSerializer,
  secret_key: to_string(Mix.env)

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [uid_field: "login"]},
    identity: {Ueberauth.Stragey.Identity, []},
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
