defmodule BookingWeb.LocationsSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable, Schema, Booking}

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
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    query = "{ locations { id name } }"
    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{"locations" => [%{"name" => "First", "id" => "#{location.id}"}]}
           }
  end
end
