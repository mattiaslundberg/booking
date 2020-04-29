defmodule Booking.Bookable do
  alias Booking.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookables" do
    field :name, :string
    belongs_to :location, Booking.Location

    has_many :bookings, Booking.Booking

    timestamps()
  end

  def create(_parent, args, _resolution) do
    %__MODULE__{} |> __MODULE__.changeset(args) |> Repo.insert()
  end

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
