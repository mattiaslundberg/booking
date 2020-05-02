defmodule Booking.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    belongs_to :location, Booking.Location
    belongs_to :user, User.Location

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:user_id, :location_id])
    |> validate_required([:user_id, :location_id])
  end
end
