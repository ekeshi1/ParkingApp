# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config



config :parking, Parking.Endpoint,
  http: [port: 4001],
  server: true  # Change the `false` to `true`


config :parking, env: Mix.env()
config :parking, Parking.Scheduler,
  jobs: [
    news_letter: [
      schedule: "@weekly",
      task: {Heartbeat, :send, []}
    ],
    mounthly_payment: [
      schedule: "@monthly",#{:extended, "*/59 * * * *"},
      task: {Parking.MounthyPay, :pay_all, []}
    ]
  ]


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
config :logger, :console,level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :hound, driver: "chrome_driver"
config :parking, sql_sandbox: true

config :parking, Parking.Guardian,
  issuer: "parking",
  secret_key: "Ub99nZwGDol3hH3Ghgd0mxheOdvRhL4THNhbI8JG4prvoGRBy5tuTW9kxj1+gv6O"


config :parking, Parking.Mailer,
  mailgun_domain: "sandboxd6bc43eee9304e5f86d13156763f2e32.mailgun.org",
  mailgun_key: "0c10ee817bcbca1589a79ba90b28d7bf-95f6ca46-f250a3de"
