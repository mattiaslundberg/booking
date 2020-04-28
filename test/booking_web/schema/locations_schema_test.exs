defmodule BookingWeb.LocationsSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo, Bookable}

  test "empty", %{conn: conn} do
    query = "{ locations { id } }"

    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{"data" => %{"locations" => []}}
  end

  test "non empty with id and name", %{conn: conn} do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    query = "{ locations { id name } }"
    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{"locations" => [%{"name" => "First", "id" => "#{location.id}"}]}
           }
  end

  test "non empty without bookables", %{conn: conn} do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()
    query = "{ locations { id bookables { id } } }"
    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{"locations" => [%{"id" => "#{location.id}", "bookables" => []}]}
           }
  end

  test "with bookables", %{conn: conn} do
    location = %Location{} |> Location.changeset(%{name: "First"}) |> Repo.insert!()

    bookable =
      %Bookable{}
      |> Bookable.changeset(%{name: "Bookable", location_id: location.id})
      |> Repo.insert!()

    query = "{ locations { id bookables { id } } }"
    res = post(conn, "/graphql", query: query)

    assert json_response(res, 200) == %{
             "data" => %{
               "locations" => [
                 %{"id" => "#{location.id}", "bookables" => [%{"id" => "#{bookable.id}"}]}
               ]
             }
           }
  end
end
