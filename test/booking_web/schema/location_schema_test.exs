defmodule BookingWeb.LocationSchemaTest do
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

  test "non existing", %{user: user} do
    query = "{ location(id: 999) { id } }"
    {:ok, %{data: data}} = Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})

    assert data == %{"location" => nil}
  end

  test "without permission", %{user: user} do
    location = %Location{} |> Location.changeset(%{name: "Other"}) |> Repo.insert!()

    query = "{ location(id: #{location.id}) { id } }"
    {:ok, %{data: data}} = Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})

    assert data == %{"location" => nil}
  end

  test "with bookables", %{user: user, location: location} do
    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    query = "{ location(id: #{location.id}) { id bookables { id } } }"
    {:ok, %{data: data}} = Absinthe.run(query, Booking.Schema, context: %{user_id: user.id})

    assert data == %{
             "location" => %{
               "id" => "#{location.id}",
               "bookables" => [%{"id" => "#{bookable.id}"}]
             }
           }
  end
end
