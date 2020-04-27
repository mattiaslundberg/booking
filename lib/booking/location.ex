defmodule Booking.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string

    has_many :bookables, Booking.Bookable

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
