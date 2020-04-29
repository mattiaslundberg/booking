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
    |> validate_start_end(booking)
  end

  defp validate_start_end(changeset = %{changes: changes}, previous),
    do:
      do_validate(
        get_value(changes, previous, :start),
        get_value(changes, previous, :end),
        changeset
      )

  defp do_validate(start, stop, changeset) when start <= stop, do: changeset

  defp do_validate(_, _, changeset),
    do: add_error(changeset, :end, ~S|Expected "start" to be before "end".|)

  defp get_value(first, second, key, default \\ nil),
    do: Map.get(first, key, Map.get(second, key, default))
end
