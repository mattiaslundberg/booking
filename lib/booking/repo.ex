defmodule Booking.Repo do
  use Ecto.Repo,
    otp_app: :booking,
    adapter: Ecto.Adapters.Postgres
end
