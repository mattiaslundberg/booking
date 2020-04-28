defmodule Booking.Repo.Migrations.BookingTimes do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :start, :utc_datetime
      add :end, :utc_datetime
    end
  end
end
