defmodule Booking.Repo.Migrations.BookableLocation do
  use Ecto.Migration

  def change do
    alter table(:bookables) do
      add :location_id, references(:locations)
    end
  end
end
