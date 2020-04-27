defmodule BookingWeb.LocationsSchemaTest do
  use BookingWeb.ConnCase
  alias Booking.{Location, Repo}

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

  test "with bookables"

  test "with bookables with bookings"
end
