defmodule Booking.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :label, :string

      add :bookable_id, references(:bookables)
      timestamps()
    end
  end
end
