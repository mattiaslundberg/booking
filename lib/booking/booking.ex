defmodule Booking.Booking do
  use Ecto.Schema
  import Ecto.Changeset
  alias Booking.Repo

  schema "bookings" do
    field :label, :string
    field :start, :utc_datetime
    field :end, :utc_datetime

    belongs_to :bookable, Booking.Bookable

    timestamps()
  end

  def create(_parent, args, _resolution) do
    %__MODULE__{} |> __MODULE__.changeset(args) |> Repo.insert()
  end

  def update(_parent, args = %{id: id}, _resolution) do
    __MODULE__ |> Repo.get(id) |> __MODULE__.changeset(args) |> Repo.update()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:label, :bookable_id, :start, :end])
    |> validate_required([:label, :bookable_id, :start, :end])
  end
end
