defmodule BookingWeb.UpdateBookableTest do
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

    {:ok, bookable} =
      Bookable.create(nil, %{location_id: location.id, name: "Bookable"}, %{
        context: %{user_id: user.id}
      })

    %{
      bookable: bookable,
      location: location,
      permission: permission,
      user: user,
      conn: build_conn()
    }
  end

  test "update successful", %{location: location, bookable: bookable, user: user} do
    query = """
    mutation {
      updateBookable(id: #{bookable.id} locationId: #{location.id} name:"From graph") {
        name id
      }
    }
    """

    assert {:ok, %{data: %{"updateBookable" => %{"name" => "From graph"}}}} =
             Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})
  end
end
