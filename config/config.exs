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
  secret_key_base: "lpeRBBp/7xSxiYExBRto06jeTW5gKNzlIC8eK5HPIyHsgQm1kKNjrQtf3k1AI3Zc",
  debug_errors: false,
  pubsub: [name: PhoenixGuardian.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :joken,
       secret_key: "lksjdflksjfowieruwoieruowier",
       json_module: Guardian.JWT

config :guardian, Guardian,
      issuer: "MyApp",
      ttl: { 100_000, :days },
      verify_issuer: true,
      secret_key: "lksdjowiurowieurlkjsdlwwer",
      serializer: PhoenixGuardian.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
