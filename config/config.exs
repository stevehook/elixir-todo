# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :todo, Todo.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "+wK5WJZvG3Etd9X9LGRKVNSzgoPNGQEw9VwPXIbeT09JcW5b/632WKJyWHnqCQc/",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Todo.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :todo, ecto_repos: [Todo.Repo]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Todo",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "somelongkeythatweneedtochangeinproduction",
  serializer: Todo.GuardianSerializer
