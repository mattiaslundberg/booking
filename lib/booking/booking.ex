defmodule Booking.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :label, :string
    field :start, :utc_datetime
    field :end, :utc_datetime

    belongs_to :bookable, Booking.Bookable

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:label, :bookable_id, :start, :end])
    |> validate_required([:label, :bookable_id, :start, :end])
  end
end
