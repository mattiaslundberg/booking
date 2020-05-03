defmodule Booking.Location do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Booking.Repo

  schema "locations" do
    field :name, :string

    has_many :bookables, Booking.Bookable
    many_to_many :users, Booking.User, join_through: "permissions"

    timestamps()
  end

  def all(_, _, %{context: %{user_id: user_id}}) do
    {:ok,
     __MODULE__
     |> join(:inner, [l], p in Booking.Permission, on: l.id == p.location_id)
     |> where([l, p], p.user_id == ^user_id)
     |> Repo.all()}
  end

  def all(_, _, _), do: {:ok, []}

  def by_id(_, %{id: id}, _), do: {:ok, __MODULE__ |> Repo.get(id)}
  def by_id(_, _, _), do: {:ok, nil}

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
