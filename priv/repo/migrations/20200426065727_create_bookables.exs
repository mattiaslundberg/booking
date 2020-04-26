defmodule Booking.Repo.Migrations.CreateBookables do
  use Ecto.Migration

  def change do
    create table(:bookables) do
      add :name, :string

      timestamps()
    end

  end
end
