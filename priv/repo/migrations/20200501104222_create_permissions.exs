defmodule Booking.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :user_id, references(:users)
      add :location_id, references(:locations)

      timestamps()
    end

    create index(:permissions, [:user_id, :location_id])
  end
end
