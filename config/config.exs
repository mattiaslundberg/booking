# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :booking,
  ecto_repos: [Booking.Repo]

# Configures the endpoint
config :booking, BookingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EXF+Olosq5AI/cWGYPqTaKwSRmUOXcHd9BqRjwZ7S+leZCBDpP0qihbxXktgKZpU",
  render_errors: [view: BookingWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Booking.PubSub,
  live_view: [signing_salt: "t38Pc5en"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
