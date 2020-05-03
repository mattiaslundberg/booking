defmodule BookingWeb.CreateBookableTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable, User, Permission}

  setup do
    user =
      %User{}
      |> User.changeset(%{name: "User", email: "user@example.com", password: "secret"})
      |> Repo.insert!()

    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    permission =
      %Permission{}
      |> Permission.changeset(%{location_id: location.id, user_id: user.id})
      |> Repo.insert!()

    %{location: location, permission: permission, user: user, conn: build_conn()}
  end

  test "create successful", %{location: location, user: user} do
    query = """
    mutation {
      createBookable(locationId: #{location.id}, name:"From graph") {
        name id
      }
    }
    """

    {:ok, %{data: %{"createBookable" => bookable}}} =
      Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})

    assert Map.get(bookable, "name") == "From graph"

    db_bookable = Bookable |> Repo.get(Map.get(bookable, "id"))
    assert db_bookable.name == "From graph"
  end
end
