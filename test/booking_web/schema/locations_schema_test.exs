defmodule BookingWeb.LocationsSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable, Schema, Booking, User, Permission}

  test "empty" do
    query = "{ locations { id } }"
    {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{"locations" => []}
  end

  test "non empty without bookables" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    query = "{ locations { id bookables { id } } }"
    {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data ==
             %{"locations" => [%{"id" => "#{location.id}", "bookables" => []}]}
  end

  test "with bookables" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    query = "{ locations { id bookables { id } } }"

    {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{
             "locations" => [
               %{"id" => "#{location.id}", "bookables" => [%{"id" => "#{bookable.id}"}]}
             ]
           }
  end

  test "with users" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    user = %User{} |> User.changeset(%{name: "User", email: "user@example.com"}) |> Repo.insert!()

    %Permission{}
    |> Permission.changeset(%{user_id: user.id, location_id: location.id})
    |> Repo.insert!()

    query = "{ locations { id users { email name } } }"

    assert {:ok,
            %{
              data: %{
                "locations" => [
                  %{"users" => [%{"name" => "User", "email" => "user@example.com"}]}
                ]
              }
            }} = Absinthe.run(query, Schema)
  end

  test "with bookings" do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

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

    {:ok, %{data: data}} = Absinthe.run(query, Schema)

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

  test "http non empty with id and name", %{conn: conn} do
    user =
      %User{}
      |> User.changeset(%{name: "First", email: "test@example.com", password: "secret"})
      |> Repo.insert!()

    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    %Permission{}
    |> Permission.changeset(%{location_id: location.id, user_id: user.id})
    |> Repo.insert!()

    query = "{ locations { id name } }"

    token =
      conn
      |> post("/login", %{email: user.email, password: "secret"})
      |> Map.get(:resp_body)
      |> Jason.decode!()
      |> Map.get("token")

    res =
      conn |> Map.put(:req_headers, [{"x-user-token", token}]) |> post("/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{"locations" => [%{"name" => "First", "id" => "#{location.id}"}]}
           }
  end
end
