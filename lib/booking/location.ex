defmodule Booking.Location do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Booking.Repo

  @moduledoc """
  Location, keeps a list of bookables and is the entity to which access is given
  """

  schema "locations" do
    field :name, :string

    has_many :bookables, Booking.Bookable
    many_to_many :users, Booking.User, join_through: "permissions"

    timestamps()
  end

  defp base_query(user_id) do
    __MODULE__
    |> join(:inner, [l], p in Booking.Permission, on: l.id == p.location_id)
    |> where([l, p], p.user_id == ^user_id)
  end

  def all(_, _, %{context: %{user_id: user_id}}) do
    {:ok, base_query(user_id) |> Repo.all()}
  end

  def all(_, _, _), do: {:ok, []}

  def by_id(_, %{id: id}, %{context: %{user_id: user_id}}),
    do: {:ok, base_query(user_id) |> Repo.get(id)}

  def by_id(_, _, _), do: {:ok, nil}

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
