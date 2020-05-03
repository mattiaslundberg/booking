defmodule Booking.Bookable do
  alias Booking.Repo
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "bookables" do
    field :name, :string
    belongs_to :location, Booking.Location

    has_many :bookings, Booking.Booking

    timestamps()
  end

  def create(_parent, args = %{location_id: location_id}, %{context: %{user_id: user_id}}) do
    location =
      Booking.Location
      |> join(:inner, [l], p in Booking.Permission, on: l.id == p.location_id)
      |> where([l, p], p.user_id == ^user_id)
      |> Repo.get(location_id)

    do_create(args, location)
  end

  def create(_, _, _), do: {:error, :denied}

  defp do_create(args, %{id: location_id}) when is_number(location_id) do
    %__MODULE__{} |> __MODULE__.changeset(%{args | location_id: location_id}) |> Repo.insert()
  end

  defp do_create(_, _), do: {:error, :denied}

  def update(_parent, args = %{id: id}, _resolution) do
    __MODULE__ |> Repo.get(id) |> __MODULE__.changeset(args) |> Repo.update()
  end

  @doc false
  def changeset(bookable, attrs) do
    bookable
    |> cast(attrs, [:name, :location_id])
    |> validate_required([:name, :location_id])
  end
end
