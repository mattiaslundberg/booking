defmodule Booking.Booking do
  use Ecto.Schema
  import Ecto.Changeset
  alias Booking.{Repo, Bookable}

  schema "bookings" do
    field :label, :string
    field :start, :utc_datetime
    field :end, :utc_datetime

    belongs_to :bookable, Booking.Bookable

    timestamps()
  end

  def create(_parent, args, %{context: %{user_id: user_id}}) do
    user_id
    |> Bookable.base_query()
    |> Repo.one()
    |> do_create(args)
  end

  def create(_, _, _), do: {:error, :denied}

  defp do_create(%{id: bookable_id}, args) do
    %__MODULE__{} |> __MODULE__.changeset(%{args | bookable_id: bookable_id}) |> Repo.insert()
  end

  defp do_create(_, _), do: {:error, :denied}

  def update(_parent, args = %{id: id}, %{context: %{user_id: user_id}}) do
    bookable = user_id |> Bookable.base_query() |> Repo.one()

    __MODULE__
    |> Repo.get(id)
    |> do_update(args, bookable)
  end

  defp do_update(booking, args, %{id: bookable_id}) do
    booking
    |> __MODULE__.changeset(%{args | bookable_id: bookable_id})
    |> Repo.update()
  end

  defp do_update(_, _, _), do: {:error, :denied}

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
