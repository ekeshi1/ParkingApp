# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :parking,
  ecto_repos: [Parking.Repo]

# Configures the endpoint
config :parking, ParkingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9+c798i5n5cOSr7YDQSyPfeluBnTmnOqoyb3iYb2Qt9yb7pM0klnIBqHchAXSv4g",
  render_errors: [view: ParkingWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Parking.PubSub,
  live_view: [signing_salt: "G2RD4BO5"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"