use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :booking, Booking.Repo,
  username: "postgres",
  password: "postgres",
  database: "booking_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  port: 5434,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :booking, BookingWeb.Endpoint,
  http: [port: 4002],
  server: false

config :booking, hash_fun: :md5

# Print only warnings and errors during test
config :logger, level: :warn
