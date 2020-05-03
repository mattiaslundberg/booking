defmodule Booking.Bookable do
  alias Booking.Repo
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "bookables" do
    field :name, :string
    belongs_to :location, Booking.Location

    has_many :bookings, Booking.Booking

    timestamps()
  end

  def base_query(user_id) do
    __MODULE__
    |> join(:inner, [b], l in Booking.Location, on: b.location_id == l.id)
    |> join(:inner, [b, l], p in Booking.Permission, on: l.id == p.location_id)
    |> where([b, l, p], p.user_id == ^user_id)
  end

  def create(_parent, args = %{location_id: location_id}, res) do
    {:ok, location} = Booking.Location.by_id(nil, %{id: location_id}, res)

    do_create(args, location)
  end

  def create(_, _, _), do: {:error, :denied}

  defp do_create(args, %{id: location_id}) when is_number(location_id) do
    %__MODULE__{} |> __MODULE__.changeset(%{args | location_id: location_id}) |> Repo.insert()
  end

  defp do_create(_, _), do: {:error, :denied}

  def update(_parent, args = %{id: id, location_id: location_id}, res) do
    {:ok, location} = Booking.Location.by_id(nil, %{id: location_id}, res)

    __MODULE__
    |> Repo.get(id)
    |> __MODULE__.changeset(%{args | location_id: location.id})
    |> Repo.update()
  end

  def update(_, _, _), do: {:error, :denied}
  @doc false
  def changeset(bookable, attrs) do
    bookable
    |> cast(attrs, [:name, :location_id])
    |> validate_required([:name, :location_id])
  end
end
