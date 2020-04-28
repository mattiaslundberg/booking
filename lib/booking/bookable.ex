defmodule Booking.Bookable do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookables" do
    field :name, :string
    belongs_to :location, Booking.Location

    has_many :bookings, Booking.Booking

    timestamps()
  end

  @doc false
  def changeset(bookable, attrs) do
    bookable
    |> cast(attrs, [:name, :location_id])
    |> validate_required([:name, :location_id])
  end
end
