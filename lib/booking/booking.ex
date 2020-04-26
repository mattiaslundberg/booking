defmodule Booking.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :label, :string
    belongs_to :bookable, Booking.Bookable

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:label, :bookable])
    |> validate_required([:label, :bookable])
  end
end
