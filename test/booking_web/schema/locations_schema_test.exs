defmodule BookingWeb.LocationsSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable, Schema, Booking, User, Permission}

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

  test "not including locations without access", %{user: user, location: location} do
    %Location{} |> Location.changeset(%{name: "Other"}) |> Repo.insert!()
    query = "{ locations { id } }"
    {:ok, %{data: data}} = Absinthe.run(query, Schema, context: %{user_id: user.id})

    assert data ==
             %{"locations" => [%{"id" => "#{location.id}"}]}
  end

  test "non empty without bookables", %{user: user, location: location} do
    query = "{ locations { id bookables { id } } }"
    {:ok, %{data: data}} = Absinthe.run(query, Schema, context: %{user_id: user.id})

    assert data ==
             %{"locations" => [%{"id" => "#{location.id}", "bookables" => []}]}
  end

  test "with bookables", %{user: user, location: location} do
    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    query = "{ locations { id bookables { id } } }"

    {:ok, %{data: data}} = Absinthe.run(query, Schema, context: %{user_id: user.id})

    assert data == %{
             "locations" => [
               %{"id" => "#{location.id}", "bookables" => [%{"id" => "#{bookable.id}"}]}
             ]
           }
  end

  test "with users", %{user: user} do
    query = "{ locations { id users { email name } } }"

    assert {:ok,
            %{
              data: %{
                "locations" => [
                  %{"users" => [%{"name" => "User", "email" => "user@example.com"}]}
                ]
              }
            }} = Absinthe.run(query, Schema, context: %{user_id: user.id})
  end

  test "with bookings", %{user: user, location: location} do
    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    booking =
      %Booking{}
      |> Booking.changeset(%{
        label: "My booking",
        bookable_id: bookable.id,
        start: DateTime.utc_now(),
        end: DateTime.utc_now()
      })
      |> Repo.insert!()

    query = "{ locations { id bookables { id bookings { id label } } } }"

    {:ok, %{data: data}} = Absinthe.run(query, Schema, context: %{user_id: user.id})

    assert data == %{
             "locations" => [
               %{
                 "id" => "#{location.id}",
                 "bookables" => [
                   %{
                     "id" => "#{bookable.id}",
                     "bookings" => [
                       %{"id" => "#{booking.id}", "label" => "My booking"}
                     ]
                   }
                 ]
               }
             ]
           }
  end

  test "http non empty with id and name", %{conn: conn, user: user, location: location} do
    token =
      conn
      |> post("/login", %{email: user.email, password: "secret"})
      |> Map.get(:resp_body)
      |> Jason.decode!()
      |> Map.get("token")

    query = "{ locations { id name } }"

    res =
      conn |> Map.put(:req_headers, [{"x-user-token", token}]) |> post("/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{"locations" => [%{"name" => "First", "id" => "#{location.id}"}]}
           }
  end
end
